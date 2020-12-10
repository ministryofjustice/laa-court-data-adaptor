# typed: true
# frozen_string_literal: true

require "ostruct"
require "caveats"
require "cli/parser"
require "unlink"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def link_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `link`, `ln` [<options>] <formula>

        Symlink all of <formula>'s installed files into Homebrew's prefix. This
        is done automatically when you install formulae but can be useful for DIY
        installations.
      EOS
      switch "--overwrite",
             description: "Delete files that already exist in the prefix while linking."
      switch "-n", "--dry-run",
             description: "List files which would be linked or deleted by "\
                          "`brew link --overwrite` without actually linking or deleting any files."
      switch "-f", "--force",
             description: "Allow keg-only formulae to be linked."

      min_named :keg
    end
  end

  def link
    args = link_args.parse

    options = {
      overwrite: args.overwrite?,
      dry_run:   args.dry_run?,
      verbose:   args.verbose?,
    }

    args.named.to_kegs.each do |keg|
      keg_only = Formulary.keg_only?(keg.rack)

      if keg.linked?
        opoo "Already linked: #{keg}"
        name_and_flag = if keg_only
          "--force #{keg.name}"
        else
          keg.name
        end
        puts <<~EOS
          To relink:
            brew unlink #{keg.name} && brew link #{name_and_flag}
        EOS
        next
      end

      if args.dry_run?
        if args.overwrite?
          puts "Would remove:"
        else
          puts "Would link:"
        end
        keg.link(**options)
        puts_keg_only_path_message(keg) if keg_only
        next
      end

      formula = begin
        keg.to_formula
      rescue FormulaUnavailableError
        # Not all kegs may belong to formulae e.g. with `brew diy`
        nil
      end

      if keg_only
        if Homebrew.default_prefix? && formula.present? && formula.keg_only_reason.by_macos?
          caveats = Caveats.new(formula)
          opoo <<~EOS
            Refusing to link macOS provided/shadowed software: #{keg.name}
            #{caveats.keg_only_text(skip_reason: true).strip}
          EOS
          next
        end

        if !args.force? && (formula.blank? || !formula.keg_only_reason.versioned_formula?)
          opoo "#{keg.name} is keg-only and must be linked with --force"
          puts_keg_only_path_message(keg)
          next
        end
      end

      Unlink.unlink_versioned_formulae(formula, verbose: args.verbose?) if formula

      keg.lock do
        print "Linking #{keg}... "
        puts if args.verbose?

        begin
          n = keg.link(**options)
        rescue Keg::LinkError
          puts
          raise
        else
          puts "#{n} symlinks created"
        end

        puts_keg_only_path_message(keg) if keg_only && !Homebrew::EnvConfig.developer?
      end
    end
  end

  def puts_keg_only_path_message(keg)
    bin = keg/"bin"
    sbin = keg/"sbin"
    return if !bin.directory? && !sbin.directory?

    opt = HOMEBREW_PREFIX/"opt/#{keg.name}"
    puts "\nIf you need to have this software first in your PATH instead consider running:"
    puts "  #{Utils::Shell.prepend_path_in_profile(opt/"bin")}"  if bin.directory?
    puts "  #{Utils::Shell.prepend_path_in_profile(opt/"sbin")}" if sbin.directory?
  end
end
