# typed: true
# frozen_string_literal: true

require "cli/parser"
require "formula"
require "livecheck/livecheck"
require "livecheck/strategy"

module Homebrew
  extend T::Sig

  module_function

  WATCHLIST_PATH = (
    ENV["HOMEBREW_LIVECHECK_WATCHLIST"] ||
    "#{Dir.home}/.brew_livecheck_watchlist"
  ).freeze

  sig { returns(CLI::Parser) }
  def livecheck_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `livecheck` [<formulae>]

        Check for newer versions of formulae from upstream.

        If no formula argument is passed, the list of formulae to check is taken from `HOMEBREW_LIVECHECK_WATCHLIST`
        or `~/.brew_livecheck_watchlist`.
      EOS
      switch "--full-name",
             description: "Print formulae with fully-qualified names."
      flag   "--tap=",
             description: "Check formulae within the given tap, specified as <user>`/`<repo>."
      switch "--all",
             description: "Check all available formulae."
      switch "--installed",
             description: "Check formulae that are currently installed."
      switch "--newer-only",
             description: "Show the latest version only if it's newer than the formula."
      switch "--json",
             description: "Output information in JSON format."
      switch "-q", "--quiet",
             description: "Suppress warnings, don't print a progress bar for JSON output."
      conflicts "--debug", "--json"
      conflicts "--tap=", "--all", "--installed"
    end
  end

  def livecheck
    args = livecheck_args.parse

    if args.debug? && args.verbose?
      puts args
      puts ENV["HOMEBREW_LIVECHECK_WATCHLIST"] if ENV["HOMEBREW_LIVECHECK_WATCHLIST"].present?
    end

    formulae_to_check = if args.tap
      Tap.fetch(args.tap).formula_names.map { |name| Formula[name] }
    elsif args.installed?
      Formula.installed
    elsif args.all?
      Formula
    elsif (formulae_args = args.named.to_formulae) && formulae_args.present?
      formulae_args
    elsif File.exist?(WATCHLIST_PATH)
      begin
        Pathname.new(WATCHLIST_PATH).read.lines.map do |line|
          next if line.start_with?("#")

          Formula[line.strip]
        end.compact
      rescue Errno::ENOENT => e
        onoe e
      end
    end

    raise UsageError, "No formulae to check." if formulae_to_check.blank?

    Livecheck.livecheck_formulae(formulae_to_check, args)
  end
end
