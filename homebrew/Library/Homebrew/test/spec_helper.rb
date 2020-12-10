# typed: false
# frozen_string_literal: true

if ENV["HOMEBREW_TESTS_COVERAGE"]
  require "simplecov"

  formatters = [SimpleCov::Formatter::HTMLFormatter]
  if ENV["HOMEBREW_CODECOV_TOKEN"] && RUBY_PLATFORM[/darwin/]
    require "codecov"

    formatters << SimpleCov::Formatter::Codecov

    if ENV["TEST_ENV_NUMBER"]
      SimpleCov.at_exit do
        result = SimpleCov.result
        result.format! if ParallelTests.number_of_running_processes <= 1
      end
    end

    ENV["CODECOV_TOKEN"] = ENV["HOMEBREW_CODECOV_TOKEN"]
  end

  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(formatters)
end

require "rspec/its"
require "rspec/wait"
require "rspec/retry"
require "rspec/sorbet"
require "rubocop"
require "rubocop/rspec/support"
require "find"
require "byebug"
require "timeout"

$LOAD_PATH.push(File.expand_path("#{ENV["HOMEBREW_LIBRARY"]}/Homebrew/test/support/lib"))

require_relative "../global"

require "test/support/no_seed_progress_formatter"
require "test/support/github_formatter"
require "test/support/helper/cask"
require "test/support/helper/fixtures"
require "test/support/helper/formula"
require "test/support/helper/mktmpdir"
require "test/support/helper/output_as_tty"

require "test/support/helper/spec/shared_context/homebrew_cask" if OS.mac?
require "test/support/helper/spec/shared_context/integration_test"
require "test/support/helper/spec/shared_examples/formulae_exist"

TEST_DIRECTORIES = [
  CoreTap.instance.path/"Formula",
  HOMEBREW_CACHE,
  HOMEBREW_CACHE_FORMULA,
  HOMEBREW_CELLAR,
  HOMEBREW_LOCKS,
  HOMEBREW_LOGS,
  HOMEBREW_TEMP,
].freeze

# Make `instance_double` and `class_double`
# work when type-checking is active.
RSpec::Sorbet.allow_doubles!

RSpec.configure do |config|
  config.order = :random

  config.raise_errors_for_deprecations!

  config.filter_run_when_matching :focus

  config.silence_filter_announcements = true if ENV["TEST_ENV_NUMBER"]

  config.expect_with :rspec do |c|
    c.max_formatted_output_length = 200
  end

  # Use rspec-retry in CI.
  if ENV["CI"]
    config.verbose_retry = true
    config.display_try_failure_messages = true

    config.around(:each, :integration_test) do |example|
      example.metadata[:timeout] ||= 120
      example.run
    end

    config.around(:each, :needs_network) do |example|
      example.metadata[:timeout] ||= 120
      example.run_with_retry retry: 5, retry_wait: 5
    end
  end

  # Never truncate output objects.
  RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = nil

  config.include(FileUtils)

  config.include(RuboCop::RSpec::ExpectOffense)

  config.include(Test::Helper::Cask)
  config.include(Test::Helper::Fixtures)
  config.include(Test::Helper::Formula)
  config.include(Test::Helper::MkTmpDir)
  config.include(Test::Helper::OutputAsTTY)

  config.before(:each, :needs_compat) do
    skip "Requires the compatibility layer." if ENV["HOMEBREW_NO_COMPAT"]
  end

  config.before(:each, :needs_linux) do
    skip "Not running on Linux." unless OS.linux?
  end

  config.before(:each, :needs_macos) do
    skip "Not running on macOS." unless OS.mac?
  end

  config.before(:each, :needs_java) do
    java_installed = if OS.mac?
      Utils.popen_read("/usr/libexec/java_home", "--failfast")
      $CHILD_STATUS.success?
    else
      which("java")
    end
    skip "Java is not installed." unless java_installed
  end

  config.before(:each, :needs_python) do
    skip "Python is not installed." unless which("python")
  end

  config.before(:each, :needs_network) do
    skip "Requires network connection." unless ENV["HOMEBREW_TEST_ONLINE"]
  end

  config.before(:each, :needs_svn) do
    svn_shim = HOMEBREW_SHIMS_PATH/"scm/svn"
    skip "Subversion is not installed." unless quiet_system svn_shim, "--version"

    svn_shim_path = Pathname(Utils.popen_read(svn_shim, "--homebrew=print-path").chomp.presence)
    svn_paths = PATH.new(ENV["PATH"])
    svn_paths.prepend(svn_shim_path.dirname)

    if OS.mac?
      xcrun_svn = Utils.popen_read("xcrun", "-f", "svn")
      svn_paths.append(File.dirname(xcrun_svn)) if $CHILD_STATUS.success? && xcrun_svn.present?
    end

    svn = which("svn", svn_paths)
    skip "svn is not installed." unless svn

    svnadmin = which("svnadmin", svn_paths)
    skip "svnadmin is not installed." unless svnadmin

    ENV["PATH"] = PATH.new(ENV["PATH"])
                      .append(svn.dirname)
                      .append(svnadmin.dirname)
  end

  config.before(:each, :needs_unzip) do
    skip "Unzip is not installed." unless which("unzip")
  end

  config.around do |example|
    def find_files
      Find.find(TEST_TMPDIR)
          .reject { |f| File.basename(f) == ".DS_Store" }
          .map { |f| f.sub(TEST_TMPDIR, "") }
    end

    begin
      Homebrew.raise_deprecation_exceptions = true

      Formulary.clear_cache
      Tap.clear_cache
      DependencyCollector.clear_cache
      Formula.clear_cache
      Keg.clear_cache
      Tab.clear_cache
      FormulaInstaller.clear_attempted
      FormulaInstaller.clear_installed

      TEST_DIRECTORIES.each(&:mkpath)

      @__homebrew_failed = Homebrew.failed?

      @__files_before_test = find_files

      @__env = ENV.to_hash # dup doesn't work on ENV

      @__stdout = $stdout.clone
      @__stderr = $stderr.clone

      if (example.metadata.keys & [:focus, :byebug]).empty? && !ENV.key?("VERBOSE_TESTS")
        $stdout.reopen(File::NULL)
        $stderr.reopen(File::NULL)
      end

      begin
        timeout = example.metadata.fetch(:timeout, 60)
        Timeout.timeout(timeout) do
          example.run
        end
      rescue Timeout::Error => e
        example.example.set_exception(e)
      end
    rescue SystemExit => e
      example.example.set_exception(e)
    ensure
      ENV.replace(@__env)

      $stdout.reopen(@__stdout)
      $stderr.reopen(@__stderr)
      @__stdout.close
      @__stderr.close

      Formulary.clear_cache
      Tap.clear_cache
      DependencyCollector.clear_cache
      Formula.clear_cache
      Keg.clear_cache
      Tab.clear_cache

      FileUtils.rm_rf [
        TEST_DIRECTORIES.map(&:children),
        *Keg::MUST_EXIST_SUBDIRECTORIES,
        HOMEBREW_LINKED_KEGS,
        HOMEBREW_PINNED_KEGS,
        HOMEBREW_PREFIX/"var",
        HOMEBREW_PREFIX/"Caskroom",
        HOMEBREW_PREFIX/"Frameworks",
        HOMEBREW_LIBRARY/"Taps/homebrew/homebrew-cask",
        HOMEBREW_LIBRARY/"Taps/homebrew/homebrew-bar",
        HOMEBREW_LIBRARY/"Taps/homebrew/homebrew-bundle",
        HOMEBREW_LIBRARY/"Taps/homebrew/homebrew-foo",
        HOMEBREW_LIBRARY/"Taps/homebrew/homebrew-services",
        HOMEBREW_LIBRARY/"Taps/homebrew/homebrew-shallow",
        HOMEBREW_LIBRARY/"PinnedTaps",
        HOMEBREW_REPOSITORY/".git",
        CoreTap.instance.path/".git",
        CoreTap.instance.alias_dir,
        CoreTap.instance.path/"formula_renames.json",
        CoreTap.instance.path/"tap_migrations.json",
        CoreTap.instance.path/"audit_exceptions",
        CoreTap.instance.path/"style_exceptions",
        CoreTap.instance.path/"pypi_formula_mappings.json",
        *Pathname.glob("#{HOMEBREW_CELLAR}/*/"),
      ]

      files_after_test = find_files

      diff = Set.new(@__files_before_test) ^ Set.new(files_after_test)
      expect(diff).to be_empty, <<~EOS
        file leak detected:
        #{diff.map { |f| "  #{f}" }.join("\n")}
      EOS

      Homebrew.failed = @__homebrew_failed
    end
  end
end

RSpec::Matchers.define_negated_matcher :not_to_output, :output
RSpec::Matchers.alias_matcher :have_failed, :be_failed
RSpec::Matchers.alias_matcher :a_string_containing, :include

RSpec::Matchers.define :a_json_string do
  match do |actual|
    JSON.parse(actual)
    true
  rescue JSON::ParserError
    false
  end
end

# Match consecutive elements in an array.
RSpec::Matchers.define :array_including_cons do |*cons|
  match do |actual|
    expect(actual.each_cons(cons.size)).to include(cons)
  end
end
