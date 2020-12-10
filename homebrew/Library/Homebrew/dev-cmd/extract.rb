# typed: false
# frozen_string_literal: true

require "cli/parser"
require "utils/git"
require "formulary"
require "software_spec"
require "tap"

def with_monkey_patch
  BottleSpecification.class_eval do
    alias_method :old_method_missing, :method_missing if method_defined?(:method_missing)
    define_method(:method_missing) { |*| }
  end

  Module.class_eval do
    alias_method :old_method_missing, :method_missing if method_defined?(:method_missing)
    define_method(:method_missing) { |*| }
  end

  Resource.class_eval do
    alias_method :old_method_missing, :method_missing if method_defined?(:method_missing)
    define_method(:method_missing) { |*| }
  end

  DependencyCollector.class_eval do
    alias_method :old_parse_symbol_spec, :parse_symbol_spec if method_defined?(:parse_symbol_spec)
    define_method(:parse_symbol_spec) { |*| }
  end

  if defined?(DependencyCollector::Compat)
    DependencyCollector::Compat.class_eval do
      alias_method :old_parse_string_spec, :parse_string_spec if method_defined?(:parse_string_spec)
      define_method(:parse_string_spec) { |*| }
    end
  end

  yield
ensure
  BottleSpecification.class_eval do
    if method_defined?(:old_method_missing)
      alias_method :method_missing, :old_method_missing
      undef :old_method_missing
    end
  end

  Module.class_eval do
    if method_defined?(:old_method_missing)
      alias_method :method_missing, :old_method_missing
      undef :old_method_missing
    end
  end

  Resource.class_eval do
    if method_defined?(:old_method_missing)
      alias_method :method_missing, :old_method_missing
      undef :old_method_missing
    end
  end

  DependencyCollector.class_eval do
    if method_defined?(:old_parse_symbol_spec)
      alias_method :parse_symbol_spec, :old_parse_symbol_spec
      undef :old_parse_symbol_spec
    end
  end

  if defined?(DependencyCollector::Compat)
    DependencyCollector::Compat.class_eval do
      if method_defined?(:old_parse_string_spec)
        alias_method :parse_string_spec, :old_parse_string_spec
        undef :old_parse_string_spec
      end
    end
  end
end

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def extract_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `extract` [<options>] <formula> <tap>

        Look through repository history to find the most recent version of <formula> and
        create a copy in <tap>`/Formula/`<formula>`@`<version>`.rb`. If the tap is not
        installed yet, attempt to install/clone the tap before continuing. To extract
        a formula from a tap that is not `homebrew/core` use its fully-qualified form of
        <user>`/`<repo>`/`<formula>.
      EOS
      flag   "--version=",
             description: "Extract the specified <version> of <formula> instead of the most recent."
      switch "-f", "--force",
             description: "Overwrite the destination formula if it already exists."

      named 2
    end
  end

  def extract
    args = extract_args.parse

    if (match = args.named.first.match(HOMEBREW_TAP_FORMULA_REGEX))
      name = match[3].downcase
      source_tap = Tap.fetch(match[1], match[2])
      raise TapFormulaUnavailableError.new(source_tap, name) unless source_tap.installed?
    else
      name = args.named.first.downcase
      source_tap = CoreTap.instance
    end

    destination_tap = Tap.fetch(args.named.second)
    unless Homebrew::EnvConfig.developer?
      odie "Cannot extract formula to homebrew/core!" if destination_tap.core_tap?
      odie "Cannot extract formula to the same tap!" if destination_tap == source_tap
    end
    destination_tap.install unless destination_tap.installed?

    repo = source_tap.path
    pattern = if source_tap.core_tap?
      [repo/"Formula/#{name}.rb"]
    else
      # A formula can technically live in the root directory of a tap or in any of its subdirectories
      [repo/"#{name}.rb", repo/"**/#{name}.rb"]
    end

    if args.version
      ohai "Searching repository history"
      version = args.version
      version_segments = Gem::Version.new(version).segments if Gem::Version.correct?(version)
      rev = nil
      test_formula = nil
      result = ""
      loop do
        rev = rev.nil? ? "HEAD" : "#{rev}~1"
        rev, (path,) = Utils::Git.last_revision_commit_of_files(repo, pattern, before_commit: rev)
        if rev.nil? && source_tap.shallow?
          odie <<~EOS
            Could not find #{name} but #{source_tap} is a shallow clone!
            Try again after running:
              git -C "#{source_tap.path}" fetch --unshallow
          EOS
        elsif rev.nil?
          odie "Could not find #{name}! The formula or version may not have existed."
        end

        file = repo/path
        result = Utils::Git.last_revision_of_file(repo, file, before_commit: rev)
        if result.empty?
          odebug "Skipping revision #{rev} - file is empty at this revision"
          next
        end

        test_formula = formula_at_revision(repo, name, file, rev)
        break if test_formula.nil? || test_formula.version == version

        if version_segments && Gem::Version.correct?(test_formula.version)
          test_formula_version_segments = Gem::Version.new(test_formula.version).segments
          if version_segments.length < test_formula_version_segments.length
            odebug "Apply semantic versioning with #{test_formula_version_segments}"
            break if version_segments == test_formula_version_segments.first(version_segments.length)
          end
        end

        odebug "Trying #{test_formula.version} from revision #{rev} against desired #{version}"
      end
      odie "Could not find #{name}! The formula or version may not have existed." if test_formula.nil?
    else
      # Search in the root directory of <repo> as well as recursively in all of its subdirectories
      files = Dir[repo/"{,**/}"].map do |dir|
        Pathname.glob(["#{dir}/#{name}.rb"]).find(&:file?)
      end.compact

      if files.empty?
        ohai "Searching repository history"
        rev, (path,) = Utils::Git.last_revision_commit_of_files(repo, pattern)
        odie "Could not find #{name}! The formula or version may not have existed." if rev.nil?
        file = repo/path
        version = formula_at_revision(repo, name, file, rev).version
        result = Utils::Git.last_revision_of_file(repo, file)
      else
        file = files.first.realpath
        rev = "HEAD"
        version = Formulary.factory(file).version
        result = File.read(file)
      end
    end

    # The class name has to be renamed to match the new filename,
    # e.g. Foo version 1.2.3 becomes FooAT123 and resides in Foo@1.2.3.rb.
    class_name = Formulary.class_s(name)

    # Remove any existing version suffixes, as a new one will be added later
    name.sub!(/\b@(.*)\z\b/i, "")
    versioned_name = Formulary.class_s("#{name}@#{version}")
    result.sub!("class #{class_name} < Formula", "class #{versioned_name} < Formula")

    # Remove bottle blocks, they won't work.
    result.sub!(/  bottle do.+?end\n\n/m, "") if destination_tap != source_tap

    path = destination_tap.path/"Formula/#{name}@#{version}.rb"
    if path.exist?
      unless args.force?
        odie <<~EOS
          Destination formula already exists: #{path}
          To overwrite it and continue anyways, run:
            brew extract --force --version=#{version} #{name} #{destination_tap.name}
        EOS
      end
      odebug "Overwriting existing formula at #{path}"
      path.delete
    end
    ohai "Writing formula for #{name} from revision #{rev} to:"
    puts path
    path.write result
  end

  # @private
  def formula_at_revision(repo, name, file, rev)
    return if rev.empty?

    contents = Utils::Git.last_revision_of_file(repo, file, before_commit: rev)
    contents.gsub!("@url=", "url ")
    contents.gsub!("require 'brewkit'", "require 'formula'")
    with_monkey_patch { Formulary.from_contents(name, file, contents) }
  end
end
