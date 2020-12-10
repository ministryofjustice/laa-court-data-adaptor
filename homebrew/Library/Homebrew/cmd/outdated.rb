# typed: false
# frozen_string_literal: true

require "formula"
require "keg"
require "cli/parser"
require "cask/cmd"
require "cask/caskroom"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def outdated_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `outdated` [<options>] [<formula>|<cask>]

        List installed casks and formulae that have an updated version available. By default, version
        information is displayed in interactive shells, and suppressed otherwise.
      EOS
      switch "-q", "--quiet",
             description: "List only the names of outdated kegs (takes precedence over `--verbose`)."
      switch "-v", "--verbose",
             description: "Include detailed version information."
      switch "--formula",
             description: "List only outdated formulae."
      switch "--cask",
             description: "List only outdated casks."
      flag   "--json",
             description: "Print output in JSON format. There are two versions: v1 and v2. " \
                          "v1 is deprecated and is currently the default if no version is specified. " \
                          "v2 prints outdated formulae and casks. "
      switch "--fetch-HEAD",
             description: "Fetch the upstream repository to detect if the HEAD installation of the "\
                          "formula is outdated. Otherwise, the repository's HEAD will only be checked for "\
                          "updates when a new stable or development version has been released."
      switch "--greedy",
             description: "Print outdated casks with `auto_updates` or `version :latest`."

      conflicts "--quiet", "--verbose", "--json"
      conflicts "--formula", "--cask"
    end
  end

  def outdated
    args = outdated_args.parse

    case (j = json_version(args.json))
    when :v1, :default
      odisabled "brew outdated --json#{j == :v1 ? "=v1" : ""}", "brew outdated --json=v2"
    when :v2
      formulae, casks = if args.formula?
        [outdated_formulae(args: args), []]
      elsif args.cask?
        [[], outdated_casks(args: args)]
      else
        outdated_formulae_casks args: args
      end

      json = {
        "formulae" => json_info(formulae, args: args),
        "casks"    => json_info(casks, args: args),
      }
      puts JSON.generate(json)

      outdated = formulae + casks

    else
      outdated = if args.formula?
        outdated_formulae args: args
      elsif args.cask?
        outdated_casks args: args
      else
        outdated_formulae_casks(args: args).flatten
      end

      print_outdated(outdated, args: args)
    end

    Homebrew.failed = args.named.present? && outdated.present?
  end

  def print_outdated(formulae_or_casks, args:)
    formulae_or_casks.each do |formula_or_cask|
      if formula_or_cask.is_a?(Formula)
        f = formula_or_cask

        if verbose?
          outdated_kegs = f.outdated_kegs(fetch_head: args.fetch_HEAD?)

          current_version = if f.alias_changed? && !f.latest_formula.latest_version_installed?
            latest = f.latest_formula
            "#{latest.name} (#{latest.pkg_version})"
          elsif f.head? && outdated_kegs.any? { |k| k.version.to_s == f.pkg_version.to_s }
            # There is a newer HEAD but the version number has not changed.
            "latest HEAD"
          else
            f.pkg_version.to_s
          end

          outdated_versions = outdated_kegs.group_by { |keg| Formulary.from_keg(keg).full_name }
                                           .sort_by { |full_name, _kegs| full_name }
                                           .map do |full_name, kegs|
            "#{full_name} (#{kegs.map(&:version).join(", ")})"
          end.join(", ")

          pinned_version = " [pinned at #{f.pinned_version}]" if f.pinned?

          puts "#{outdated_versions} < #{current_version}#{pinned_version}"
        else
          puts f.full_installed_specified_name
        end
      else
        c = formula_or_cask

        puts c.outdated_info(args.greedy?, verbose?, false)
      end
    end
  end

  def json_info(formulae_or_casks, args:)
    formulae_or_casks.map do |formula_or_cask|
      if formula_or_cask.is_a?(Formula)
        f = formula_or_cask

        outdated_versions = f.outdated_kegs(fetch_head: args.fetch_HEAD?).map(&:version)
        current_version = if f.head? && outdated_versions.any? { |v| v.to_s == f.pkg_version.to_s }
          "HEAD"
        else
          f.pkg_version.to_s
        end

        { name:               f.full_name,
          installed_versions: outdated_versions.map(&:to_s),
          current_version:    current_version,
          pinned:             f.pinned?,
          pinned_version:     f.pinned_version }
      else
        c = formula_or_cask

        c.outdated_info(args.greedy?, verbose?, true)
      end
    end
  end

  def verbose?
    ($stdout.tty? || super) && !quiet?
  end

  def json_version(version)
    version_hash = {
      nil  => nil,
      true => :default,
      "v1" => :v1,
      "v2" => :v2,
    }

    raise UsageError, "invalid JSON version: #{version}" unless version_hash.include?(version)

    version_hash[version]
  end

  def outdated_formulae(args:)
    select_outdated((args.named.to_resolved_formulae.presence || Formula.installed), args: args).sort
  end

  def outdated_casks(args:)
    if args.named.present?
      select_outdated(args.named.to_casks, args: args)
    else
      select_outdated(Cask::Caskroom.casks(config: Cask::Config.from_args(args)), args: args)
    end
  end

  def outdated_formulae_casks(args:)
    formulae, casks = args.named.to_resolved_formulae_to_casks

    if formulae.blank? && casks.blank?
      formulae = Formula.installed
      casks = Cask::Caskroom.casks(config: Cask::Config.from_args(args))
    end

    [select_outdated(formulae, args: args).sort, select_outdated(casks, args: args)]
  end

  def select_outdated(formulae_or_casks, args:)
    formulae_or_casks.select do |formula_or_cask|
      if formula_or_cask.is_a?(Formula)
        formula_or_cask.outdated?(fetch_head: args.fetch_HEAD?)
      else
        formula_or_cask.outdated?(greedy: args.greedy?)
      end
    end
  end
end
