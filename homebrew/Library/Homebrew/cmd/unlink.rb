# typed: true
# frozen_string_literal: true

require "ostruct"
require "cli/parser"
require "unlink"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def unlink_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `unlink` [<options>] <formula>

        Remove symlinks for <formula> from Homebrew's prefix. This can be useful
        for temporarily disabling a formula:
        `brew unlink` <formula> `&&` <commands> `&& brew link` <formula>
      EOS
      switch "-n", "--dry-run",
             description: "List files which would be unlinked without actually unlinking or "\
                          "deleting any files."

      min_named :keg
    end
  end

  def unlink
    args = unlink_args.parse

    options = { dry_run: args.dry_run?, verbose: args.verbose? }

    args.named.to_kegs.each do |keg|
      if args.dry_run?
        puts "Would remove:"
        keg.unlink(**options)
        next
      end

      Unlink.unlink(keg, dry_run: args.dry_run?, verbose: args.verbose?)
    end
  end
end
