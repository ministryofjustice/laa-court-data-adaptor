# typed: false
# frozen_string_literal: true

require "formulary"
require "cli/parser"

class Symbol
  def f(*args)
    Formulary.factory(to_s, *args)
  end
end

class String
  def f(*args)
    Formulary.factory(self, *args)
  end
end

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def irb_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `irb` [<options>]

        Enter the interactive Homebrew Ruby shell.
      EOS
      switch "--examples",
             description: "Show several examples."
      switch "--pry",
             env:         :pry,
             description: "Use Pry instead of IRB. Implied if `HOMEBREW_PRY` is set."
    end
  end

  def irb
    # work around IRB modifying ARGV.
    args = irb_args.parse(ARGV.dup.freeze)

    if args.examples?
      puts "'v8'.f # => instance of the v8 formula"
      puts ":hub.f.latest_version_installed?"
      puts ":lua.f.methods - 1.methods"
      puts ":mpd.f.recursive_dependencies.reject(&:installed?)"
      return
    end

    if args.pry?
      Homebrew.install_gem_setup_path! "pry"
      require "pry"
      Pry.config.prompt_name = "brew"
    else
      require "irb"
    end

    require "formula"
    require "keg"
    require "cask"

    ohai "Interactive Homebrew Shell"
    puts "Example commands available with: brew irb --examples"
    if args.pry?
      Pry.start
    else
      IRB.start
    end
  end
end
