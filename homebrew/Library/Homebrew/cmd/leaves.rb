# typed: true
# frozen_string_literal: true

require "formula"
require "cli/parser"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def leaves_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `leaves`

        List installed formulae that are not dependencies of another installed formula.
      EOS

      max_named 0
    end
  end

  def leaves
    leaves_args.parse

    Formula.installed_formulae_with_no_dependents.map(&:full_name).sort.each(&method(:puts))
  end
end
