# typed: true
# frozen_string_literal: true

require "cli/parser"
require "formula"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def home_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `home` [<formula>|<cask>]

        Open a <formula> or <cask>'s homepage in a browser, or open
        Homebrew's own homepage if no argument is provided.
      EOS
    end
  end

  sig { void }
  def home
    args = home_args.parse

    if args.no_named?
      exec_browser HOMEBREW_WWW
      return
    end

    homepages = args.named.to_formulae_and_casks.map do |formula_or_cask|
      puts "Opening homepage for #{name_of(formula_or_cask)}"
      formula_or_cask.homepage
    end

    exec_browser(*T.unsafe(homepages))
  end

  def name_of(formula_or_cask)
    if formula_or_cask.is_a? Formula
      "Formula #{formula_or_cask.name}"
    else
      "Cask #{formula_or_cask.token}"
    end
  end
end
