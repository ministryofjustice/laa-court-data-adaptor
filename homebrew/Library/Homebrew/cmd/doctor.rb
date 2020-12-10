# typed: false
# frozen_string_literal: true

require "diagnostic"
require "cli/parser"
require "cask/caskroom"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def doctor_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `doctor` [<options>]

        Check your system for potential problems. Will exit with a non-zero status
        if any potential problems are found. Please note that these warnings are just
        used to help the Homebrew maintainers with debugging if you file an issue. If
        everything you use Homebrew for is working fine: please don't worry or file
        an issue; just ignore this.
      EOS
      switch "--list-checks",
             description: "List all audit methods, which can be run individually "\
                          "if provided as arguments."
      switch "-D", "--audit-debug",
             description: "Enable debugging and profiling of audit methods."
    end
  end

  def doctor
    args = doctor_args.parse

    inject_dump_stats!(Diagnostic::Checks, /^check_*/) if args.audit_debug?

    checks = Diagnostic::Checks.new(verbose: args.verbose?)

    if args.list_checks?
      puts checks.all.sort
      return
    end

    if args.no_named?
      slow_checks = %w[
        check_for_broken_symlinks
        check_missing_deps
      ]
      methods = (checks.all.sort - slow_checks) + slow_checks
      methods -= checks.cask_checks if Cask::Caskroom.casks.blank?
    else
      methods = args.named
    end

    first_warning = true
    methods.each do |method|
      $stderr.puts Formatter.headline("Checking #{method}", color: :magenta) if args.debug?
      unless checks.respond_to?(method)
        Homebrew.failed = true
        puts "No check available by the name: #{method}"
        next
      end

      out = checks.send(method)
      next if out.blank?

      if first_warning
        $stderr.puts <<~EOS
          #{Tty.bold}Please note that these warnings are just used to help the Homebrew maintainers
          with debugging if you file an issue. If everything you use Homebrew for is
          working fine: please don't worry or file an issue; just ignore this. Thanks!#{Tty.reset}
        EOS
      end

      $stderr.puts
      opoo out
      Homebrew.failed = true
      first_warning = false
    end

    puts "Your system is ready to brew." unless Homebrew.failed?
  end
end
