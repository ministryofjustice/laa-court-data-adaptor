# typed: true
# frozen_string_literal: true

require "formula"
require "cli/parser"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def unpin_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `unpin` <formula>

        Unpin <formula>, allowing them to be upgraded by `brew upgrade` <formula>.
        See also `pin`.
      EOS

      min_named :formula
    end
  end

  def unpin
    args = unpin_args.parse

    args.named.to_resolved_formulae.each do |f|
      if f.pinned?
        f.unpin
      elsif !f.pinnable?
        onoe "#{f.name} not installed"
      else
        opoo "#{f.name} not pinned"
      end
    end
  end
end
