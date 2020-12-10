# typed: false
# frozen_string_literal: true

require "missing_formula"
require "caveats"
require "cli/parser"
require "options"
require "formula"
require "keg"
require "tab"
require "json"
require "utils/spdx"
require "deprecate_disable"

module Homebrew
  extend T::Sig

  module_function

  VALID_DAYS = %w[30 90 365].freeze
  VALID_FORMULA_CATEGORIES = %w[install install-on-request build-error].freeze
  VALID_CATEGORIES = (VALID_FORMULA_CATEGORIES + %w[cask-install os-version]).freeze

  sig { returns(CLI::Parser) }
  def info_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `info` [<options>] [<formula>|<cask>]

        Display brief statistics for your Homebrew installation.

        If a <formula> or <cask> is provided, show summary of information about it.
      EOS
      switch "--analytics",
             description: "List global Homebrew analytics data or, if specified, installation and "\
                          "build error data for <formula> (provided neither `HOMEBREW_NO_ANALYTICS` "\
                          "nor `HOMEBREW_NO_GITHUB_API` are set)."
      flag   "--days=",
             depends_on:  "--analytics",
             description: "How many days of analytics data to retrieve. "\
                          "The value for <days> must be `30`, `90` or `365`. The default is `30`."
      flag   "--category=",
             depends_on:  "--analytics",
             description: "Which type of analytics data to retrieve. "\
                          "The value for <category> must be `install`, `install-on-request` or `build-error`; "\
                          "`cask-install` or `os-version` may be specified if <formula> is not. "\
                          "The default is `install`."
      switch "--github",
             description: "Open the GitHub source page for <formula> in a browser. "\
                          "To view formula history locally: `brew log -p` <formula>"
      flag   "--json",
             description: "Print a JSON representation. Currently the default value for <version> is `v1` for "\
                          "<formula>. For <formula> and <cask> use `v2`. See the docs for examples of using the "\
                          "JSON output: <https://docs.brew.sh/Querying-Brew>"
      switch "--installed",
             depends_on:  "--json",
             description: "Print JSON of formulae that are currently installed."
      switch "--all",
             depends_on:  "--json",
             description: "Print JSON of all available formulae."
      switch "-v", "--verbose",
             description: "Show more verbose analytics data for <formula>."

      switch "--formula", "--formulae",
             description: "Treat all named arguments as formulae."
      switch "--cask", "--casks",
             description: "Treat all named arguments as casks."
      conflicts "--formula", "--cask"

      conflicts "--installed", "--all"
    end
  end

  sig { void }
  def info
    args = info_args.parse

    only = :formula if args.formula? && !args.cask?
    only = :cask if args.cask? && !args.formula?

    if args.analytics?
      if args.days.present? && VALID_DAYS.exclude?(args.days)
        raise UsageError, "--days must be one of #{VALID_DAYS.join(", ")}"
      end

      if args.category.present?
        if args.named.present? && VALID_FORMULA_CATEGORIES.exclude?(args.category)
          raise UsageError, "--category must be one of #{VALID_FORMULA_CATEGORIES.join(", ")} when querying formulae"
        end

        unless VALID_CATEGORIES.include?(args.category)
          raise UsageError, "--category must be one of #{VALID_CATEGORIES.join(", ")}"
        end
      end

      print_analytics(args: args, only: only)
    elsif args.json
      print_json(args: args, only: only)
    elsif args.github?
      raise FormulaOrCaskUnspecifiedError if args.no_named?

      exec_browser(*args.named.to_formulae_and_casks(only: only).map { |f| github_info(f) })
    elsif args.no_named?
      print_statistics
    else
      print_info(args: args, only: only)
    end
  end

  sig { void }
  def print_statistics
    return unless HOMEBREW_CELLAR.exist?

    count = Formula.racks.length
    puts "#{count} #{"keg".pluralize(count)}, #{HOMEBREW_CELLAR.dup.abv}"
  end

  sig { params(args: CLI::Args, only: T.nilable(Symbol)).void }
  def print_analytics(args:, only: nil)
    if args.no_named?
      Utils::Analytics.output(args: args)
      return
    end

    args.named.to_formulae_and_casks_and_unavailable(only: only).each_with_index do |obj, i|
      puts unless i.zero?

      case obj
      when Formula
        Utils::Analytics.formula_output(obj, args: args)
      when Cask::Cask
        Utils::Analytics.cask_output(obj, args: args)
      when FormulaOrCaskUnavailableError
        Utils::Analytics.output(filter: obj.name, args: args)
      else
        raise
      end
    end
  end

  sig { params(args: CLI::Args, only: T.nilable(Symbol)).void }
  def print_info(args:, only: nil)
    args.named.to_formulae_and_casks_and_unavailable(only: only).each_with_index do |obj, i|
      puts unless i.zero?

      case obj
      when Formula
        info_formula(obj, args: args)
      when Cask::Cask
        info_cask(obj, args: args)
      when FormulaOrCaskUnavailableError
        ofail obj.message
        # No formula with this name, try a missing formula lookup
        if (reason = MissingFormula.reason(obj.name, show_info: true))
          $stderr.puts reason
        end
      else
        raise
      end
    end
  end

  def json_version(version)
    version_hash = {
      true => :default,
      "v1" => :v1,
      "v2" => :v2,
    }

    raise UsageError, "invalid JSON version: #{version}" unless version_hash.include?(version)

    version_hash[version]
  end

  sig { params(args: CLI::Args, only: T.nilable(Symbol)).void }
  def print_json(args:, only: nil)
    raise FormulaOrCaskUnspecifiedError if !(args.all? || args.installed?) && args.no_named?

    json = case json_version(args.json)
    when :v1, :default
      raise UsageError, "cannot specify --cask with --json=v1!" if args.cask?

      formulae = if args.all?
        Formula.sort
      elsif args.installed?
        Formula.installed.sort
      else
        args.named.to_formulae
      end

      formulae.map(&:to_hash)
    when :v2
      formulae, casks = if args.all?
        [Formula.sort, Cask::Cask.to_a.sort_by(&:full_name)]
      elsif args.installed?
        [Formula.installed.sort, Cask::Caskroom.casks.sort_by(&:full_name)]
      else
        args.named.to_formulae_to_casks(only: only)
      end

      {
        "formulae" => formulae.map(&:to_hash),
        "casks"    => casks.map(&:to_h),
      }
    else
      raise
    end

    puts JSON.generate(json)
  end

  def github_remote_path(remote, path)
    if remote =~ %r{^(?:https?://|git(?:@|://))github\.com[:/](.+)/(.+?)(?:\.git)?$}
      "https://github.com/#{Regexp.last_match(1)}/#{Regexp.last_match(2)}/blob/HEAD/#{path}"
    else
      "#{remote}/#{path}"
    end
  end

  def github_info(f)
    if f.tap
      if remote = f.tap.remote
        path = if f.class.superclass == Formula
          f.path.relative_path_from(f.tap.path)
        elsif f.is_a?(Cask::Cask)
          f.sourcefile_path.relative_path_from(f.tap.path)
        end
        github_remote_path(remote, path)
      else
        f.path
      end
    else
      f.path
    end
  end

  def info_formula(f, args:)
    specs = []

    if stable = f.stable
      s = "stable #{stable.version}"
      s += " (bottled)" if stable.bottled?
      specs << s
    end

    specs << "HEAD" if f.head

    attrs = []
    attrs << "pinned at #{f.pinned_version}" if f.pinned?
    attrs << "keg-only" if f.keg_only?

    puts "#{f.full_name}: #{specs * ", "}#{" [#{attrs * ", "}]" unless attrs.empty?}"
    puts f.desc if f.desc
    puts Formatter.url(f.homepage) if f.homepage

    deprecate_disable_type, deprecate_disable_reason = DeprecateDisable.deprecate_disable_info f
    if deprecate_disable_type.present?
      if deprecate_disable_reason.present?
        puts "#{deprecate_disable_type.capitalize} because it #{deprecate_disable_reason}!"
      else
        puts "#{deprecate_disable_type.capitalize}!"
      end
    end

    conflicts = f.conflicts.map do |c|
      reason = " (because #{c.reason})" if c.reason
      "#{c.name}#{reason}"
    end.sort!
    unless conflicts.empty?
      puts <<~EOS
        Conflicts with:
          #{conflicts.join("\n  ")}
      EOS
    end

    kegs = f.installed_kegs
    heads, versioned = kegs.partition { |k| k.version.head? }
    kegs = [
      *heads.sort_by { |k| -Tab.for_keg(k).time.to_i },
      *versioned.sort_by(&:version),
    ]
    if kegs.empty?
      puts "Not installed"
    else
      kegs.each do |keg|
        puts "#{keg} (#{keg.abv})#{" *" if keg.linked?}"
        tab = Tab.for_keg(keg).to_s
        puts "  #{tab}" unless tab.empty?
      end
    end

    puts "From: #{Formatter.url(github_info(f))}"

    puts "License: #{SPDX.license_expression_to_string f.license}" if f.license.present?

    unless f.deps.empty?
      ohai "Dependencies"
      %w[build required recommended optional].map do |type|
        deps = f.deps.send(type).uniq
        puts "#{type.capitalize}: #{decorate_dependencies deps}" unless deps.empty?
      end
    end

    unless f.requirements.to_a.empty?
      ohai "Requirements"
      %w[build required recommended optional].map do |type|
        reqs = f.requirements.select(&:"#{type}?")
        next if reqs.to_a.empty?

        puts "#{type.capitalize}: #{decorate_requirements(reqs)}"
      end
    end

    if !f.options.empty? || f.head
      ohai "Options"
      Options.dump_for_formula f
    end

    caveats = Caveats.new(f)
    ohai "Caveats", caveats.to_s unless caveats.empty?

    Utils::Analytics.formula_output(f, args: args)
  end

  def decorate_dependencies(dependencies)
    deps_status = dependencies.map do |dep|
      if dep.satisfied?([])
        pretty_installed(dep_display_s(dep))
      else
        pretty_uninstalled(dep_display_s(dep))
      end
    end
    deps_status.join(", ")
  end

  def decorate_requirements(requirements)
    req_status = requirements.map do |req|
      req_s = req.display_s
      req.satisfied? ? pretty_installed(req_s) : pretty_uninstalled(req_s)
    end
    req_status.join(", ")
  end

  def dep_display_s(dep)
    return dep.name if dep.option_tags.empty?

    "#{dep.name} #{dep.option_tags.map { |o| "--#{o}" }.join(" ")}"
  end

  def info_cask(cask, args:)
    require "cask/cmd/info"

    Cask::Cmd::Info.info(cask)
  end
end
