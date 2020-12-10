# typed: false
# frozen_string_literal: true

require "cli/parser"
require "fileutils"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def tests_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `tests` [<options>]

        Run Homebrew's unit and integration tests.
      EOS
      switch "--coverage",
             description: "Generate code coverage reports."
      switch "--generic",
             description: "Run only OS-agnostic tests."
      switch "--no-compat",
             description: "Do not load the compatibility layer when running tests."
      switch "--online",
             description: "Include tests that use the GitHub API and tests that use any of the taps for "\
                          "official external commands."
      switch "--byebug",
             description: "Enable debugging using byebug."
      flag   "--only=",
             description: "Run only <test_script>`_spec.rb`. Appending `:`<line_number> will start at a "\
                          "specific line."
      flag   "--seed=",
             description: "Randomise tests with the specified <value> instead of a random seed."

      max_named 0
    end
  end

  def tests
    args = tests_args.parse

    Homebrew.install_bundler_gems!

    require "byebug" if args.byebug?

    HOMEBREW_LIBRARY_PATH.cd do
      ENV.delete("HOMEBREW_COLOR")
      ENV.delete("HOMEBREW_NO_COLOR")
      ENV.delete("HOMEBREW_VERBOSE")
      ENV.delete("HOMEBREW_DEBUG")
      ENV.delete("VERBOSE")
      ENV.delete("HOMEBREW_CASK_OPTS")
      ENV.delete("HOMEBREW_TEMP")
      ENV.delete("HOMEBREW_NO_GITHUB_API")
      ENV.delete("HOMEBREW_NO_EMOJI")
      ENV.delete("HOMEBREW_DEVELOPER")
      ENV.delete("HOMEBREW_PRY")
      ENV.delete("HOMEBREW_BAT")
      ENV["HOMEBREW_NO_ANALYTICS_THIS_RUN"] = "1"
      ENV["HOMEBREW_NO_COMPAT"] = "1" if args.no_compat?
      ENV["HOMEBREW_TEST_GENERIC_OS"] = "1" if args.generic?
      ENV["HOMEBREW_TEST_ONLINE"] = "1" if args.online?
      ENV["HOMEBREW_SORBET_RUNTIME"] = "1"

      ENV["USER"] ||= system_command!("id", args: ["-nu"]).stdout.chomp

      # Avoid local configuration messing with tests, e.g. git being configured
      # to use GPG to sign by default
      ENV["HOME"] = "#{HOMEBREW_LIBRARY_PATH}/test"

      if args.coverage?
        ENV["HOMEBREW_TESTS_COVERAGE"] = "1"
        FileUtils.rm_f "test/coverage/.resultset.json"
      end

      # Override author/committer as global settings might be invalid and thus
      # will cause silent failure during the setup of dummy Git repositories.
      %w[AUTHOR COMMITTER].each do |role|
        ENV["GIT_#{role}_NAME"] = "brew tests"
        ENV["GIT_#{role}_EMAIL"] = "brew-tests@localhost"
        ENV["GIT_#{role}_DATE"]  = "Sun Jan 22 19:59:13 2017 +0000"
      end

      parallel = true

      files = if args.only
        test_name, line = args.only.split(":", 2)

        if line.nil?
          Dir.glob("test/{#{test_name},#{test_name}/**/*}_spec.rb")
        else
          parallel = false
          ["test/#{test_name}_spec.rb:#{line}"]
        end
      else
        Dir.glob("test/**/*_spec.rb")
      end

      parallel_args = if ENV["CI"]
        %w[
          --combine-stderr
          --serialize-stdout
        ]
      else
        %w[
          --nice
        ]
      end

      # Generate seed ourselves and output later to avoid multiple different
      # seeds being output when running parallel tests.
      seed = args.seed || rand(0xFFFF).to_i

      bundle_args = ["-I", HOMEBREW_LIBRARY_PATH/"test"]
      bundle_args += %W[
        --seed #{seed}
        --color
        --require spec_helper
        --format NoSeedProgressFormatter
        --format ParallelTests::RSpec::RuntimeLogger
        --out #{HOMEBREW_CACHE}/tests/parallel_runtime_rspec.log
      ]

      bundle_args << "--format" << "RSpec::Github::Formatter" if ENV["GITHUB_ACTIONS"]

      unless OS.mac?
        bundle_args << "--tag" << "~needs_macos" << "--tag" << "~cask"
        files = files.reject { |p| p =~ %r{^test/(os/mac|cask)(/.*|_spec\.rb)$} }
      end

      unless OS.linux?
        bundle_args << "--tag" << "~needs_linux"
        files = files.reject { |p| p =~ %r{^test/os/linux(/.*|_spec\.rb)$} }
      end

      puts "Randomized with seed #{seed}"

      # Let tests find `bundle` in the actual location.
      ENV["HOMEBREW_TESTS_GEM_USER_DIR"] = gem_user_dir

      # Let `bundle` in PATH find its gem.
      ENV["GEM_PATH"] = "#{ENV["GEM_PATH"]}:#{gem_user_dir}"

      if parallel
        system "bundle", "exec", "parallel_rspec", *parallel_args, "--", *bundle_args, "--", *files
      else
        system "bundle", "exec", "rspec", *bundle_args, "--", *files
      end

      return if $CHILD_STATUS.success?

      Homebrew.failed = true
    end
  end
end
