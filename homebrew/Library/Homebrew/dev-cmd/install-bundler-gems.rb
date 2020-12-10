# typed: true
# frozen_string_literal: true

require "formula"
require "cli/parser"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def install_bundler_gems_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `install-bundler-gems`

        Install Homebrew's Bundler gems.
      EOS

      max_named 0
    end
  end

  def install_bundler_gems
    install_bundler_gems_args.parse

    Homebrew.install_bundler_gems!
  end
end
