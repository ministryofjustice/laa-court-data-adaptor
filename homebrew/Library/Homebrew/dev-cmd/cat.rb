# typed: false
# frozen_string_literal: true

require "cli/parser"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def cat_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `cat` <formula>|<cask>

        Display the source of a <formula> or <cask>.
      EOS

      switch "--formula", "--formulae",
             description: "Treat all named arguments as formulae."
      switch "--cask", "--casks",
             description: "Treat all named arguments as casks."
      conflicts "--formula", "--cask"

      named :formula_or_cask
    end
  end

  def cat
    args = cat_args.parse

    only = :formula if args.formula? && !args.cask?
    only = :cask if args.cask? && !args.formula?

    cd HOMEBREW_REPOSITORY
    pager = if Homebrew::EnvConfig.bat?
      ENV["BAT_CONFIG_PATH"] = Homebrew::EnvConfig.bat_config_path
      "#{HOMEBREW_PREFIX}/bin/bat"
    else
      "cat"
    end

    safe_system pager, args.named.to_paths(only: only).first
  end
end
