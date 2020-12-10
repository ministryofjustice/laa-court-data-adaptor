# typed: true
# frozen_string_literal: true

require "keg"
require "formula"
require "linkage_cache_store"
require "fiddle"

# Check for broken/missing linkage in a formula's keg.
#
# @api private
class LinkageChecker
  extend T::Sig

  attr_reader :undeclared_deps, :keg, :formula, :store

  def initialize(keg, formula = nil, cache_db:, rebuild_cache: false)
    @keg = keg
    @formula = formula || resolve_formula(keg)
    @store = LinkageCacheStore.new(keg.to_s, cache_db)

    @system_dylibs    = Set.new
    @broken_dylibs    = Set.new
    @unexpected_broken_dylibs = nil
    @unexpected_present_dylibs = nil
    @variable_dylibs  = Set.new
    @brewed_dylibs    = Hash.new { |h, k| h[k] = Set.new }
    @reverse_links    = Hash.new { |h, k| h[k] = Set.new }
    @broken_deps      = Hash.new { |h, k| h[k] = [] }
    @indirect_deps    = []
    @undeclared_deps  = []
    @unnecessary_deps = []
    @unwanted_system_dylibs = []
    @version_conflict_deps = []

    check_dylibs(rebuild_cache: rebuild_cache)
  end

  def display_normal_output
    display_items "System libraries", @system_dylibs
    display_items "Homebrew libraries", @brewed_dylibs
    display_items "Indirect dependencies with linkage", @indirect_deps
    display_items "Variable-referenced libraries", @variable_dylibs
    display_items "Missing libraries", @broken_dylibs
    display_items "Broken dependencies", @broken_deps
    display_items "Undeclared dependencies with linkage", @undeclared_deps
    display_items "Dependencies with no linkage", @unnecessary_deps
    display_items "Unwanted system libraries", @unwanted_system_dylibs
  end

  def display_reverse_output
    return if @reverse_links.empty?

    sorted = @reverse_links.sort
    sorted.each do |dylib, files|
      puts dylib
      files.each do |f|
        unprefixed = f.to_s.delete_prefix "#{keg}/"
        puts "  #{unprefixed}"
      end
      puts if dylib != sorted.last.first
    end
  end

  def display_test_output(puts_output: true)
    display_items "Missing libraries", broken_dylibs_with_expectations, puts_output: puts_output
    display_items "Unused missing linkage information", unexpected_present_dylibs, puts_output: puts_output
    display_items "Broken dependencies", @broken_deps, puts_output: puts_output
    display_items "Unwanted system libraries", @unwanted_system_dylibs, puts_output: puts_output
    display_items "Conflicting libraries", @version_conflict_deps, puts_output: puts_output
  end

  sig { returns(T::Boolean) }
  def broken_library_linkage?
    issues = [@broken_deps, @unwanted_system_dylibs, @version_conflict_deps]
    [issues, unexpected_broken_dylibs, unexpected_present_dylibs].flatten.any?(&:present?)
  end

  def unexpected_broken_dylibs
    return @unexpected_broken_dylibs if @unexpected_broken_dylibs

    @unexpected_broken_dylibs = @broken_dylibs.reject do |broken_lib|
      @formula.class.allowed_missing_libraries.any? do |allowed_missing_lib|
        case allowed_missing_lib
        when Regexp
          allowed_missing_lib.match? broken_lib
        when String
          broken_lib.include? allowed_missing_lib
        end
      end
    end
  end

  def unexpected_present_dylibs
    @unexpected_present_dylibs ||= @formula.class.allowed_missing_libraries.reject do |allowed_missing_lib|
      @broken_dylibs.any? do |broken_lib|
        case allowed_missing_lib
        when Regexp
          allowed_missing_lib.match? broken_lib
        when String
          broken_lib.include? allowed_missing_lib
        end
      end
    end
  end

  def broken_dylibs_with_expectations
    output = {}
    @broken_dylibs.each do |broken_lib|
      output[broken_lib] = if unexpected_broken_dylibs.include? broken_lib
        ["unexpected"]
      else
        ["expected"]
      end
    end
    output
  end

  private

  def dylib_to_dep(dylib)
    dylib =~ %r{#{Regexp.escape(HOMEBREW_PREFIX)}/(opt|Cellar)/([\w+-.@]+)/}o
    Regexp.last_match(2)
  end

  def check_dylibs(rebuild_cache:)
    keg_files_dylibs = nil

    if rebuild_cache
      store&.delete!
    else
      keg_files_dylibs = store&.fetch(:keg_files_dylibs)
    end

    keg_files_dylibs_was_empty = false
    keg_files_dylibs ||= {}
    if keg_files_dylibs.empty?
      keg_files_dylibs_was_empty = true
      @keg.find do |file|
        next if file.symlink? || file.directory?
        next if !file.dylib? && !file.binary_executable? && !file.mach_o_bundle?

        # weakly loaded dylibs may not actually exist on disk, so skip them
        # when checking for broken linkage
        keg_files_dylibs[file] =
          file.dynamically_linked_libraries(except: :LC_LOAD_WEAK_DYLIB)
      end
    end

    checked_dylibs = Set.new

    keg_files_dylibs.each do |file, dylibs|
      dylibs.each do |dylib|
        @reverse_links[dylib] << file

        next if checked_dylibs.include? dylib

        checked_dylibs << dylib

        if dylib.start_with? "@"
          @variable_dylibs << dylib
          next
        end

        begin
          owner = Keg.for Pathname.new(dylib)
        rescue NotAKegError
          @system_dylibs << dylib
        rescue Errno::ENOENT
          next if harmless_broken_link?(dylib)

          if (dep = dylib_to_dep(dylib))
            @broken_deps[dep] |= [dylib]
          elsif MacOS.version >= :big_sur && dylib_found_via_dlopen(dylib)
            # If we cannot associate the dylib with a dependency, then it may be a system library.
            # In macOS Big Sur and later, system libraries do not exist on-disk and instead exist in a cache.
            # If dlopen finds the dylib, then the linkage is not broken.
            @system_dylibs << dylib
          else
            @broken_dylibs << dylib
          end
        else
          tap = Tab.for_keg(owner).tap
          f = if tap.nil? || tap.core_tap?
            owner.name
          else
            "#{tap}/#{owner.name}"
          end
          @brewed_dylibs[f] << dylib
        end
      end
    end

    if formula
      @indirect_deps, @undeclared_deps, @unnecessary_deps,
        @version_conflict_deps = check_formula_deps
    end

    return unless keg_files_dylibs_was_empty

    store&.update!(keg_files_dylibs: keg_files_dylibs)
  end
  alias generic_check_dylibs check_dylibs

  def dylib_found_via_dlopen(dylib)
    Fiddle.dlopen(dylib).close
    true
  rescue Fiddle::DLError
    false
  end

  def check_formula_deps
    filter_out = proc do |dep|
      next true if dep.build?
      next false unless dep.optional? || dep.recommended?

      formula.build.without?(dep)
    end

    declared_deps_full_names = formula.deps
                                      .reject { |dep| filter_out.call(dep) }
                                      .map(&:name)
    declared_deps_names = declared_deps_full_names.map do |dep|
      dep.split("/").last
    end
    recursive_deps = formula.runtime_formula_dependencies(undeclared: false)
                            .map(&:name)

    indirect_deps = []
    undeclared_deps = []
    @brewed_dylibs.each_key do |full_name|
      name = full_name.split("/").last
      next if name == formula.name

      if recursive_deps.include?(name)
        indirect_deps << full_name unless declared_deps_names.include?(name)
      else
        undeclared_deps << full_name
      end
    end

    sort_by_formula_full_name!(indirect_deps)
    sort_by_formula_full_name!(undeclared_deps)

    unnecessary_deps = declared_deps_full_names.reject do |full_name|
      next true if Formula[full_name].bin.directory?

      name = full_name.split("/").last
      @brewed_dylibs.keys.map { |l| l.split("/").last }.include?(name)
    end

    missing_deps = @broken_deps.values.flatten.map { |d| dylib_to_dep(d) }
    unnecessary_deps -= missing_deps

    version_hash = {}
    version_conflict_deps = Set.new
    @brewed_dylibs.each_key do |l|
      name = l.split("/").last
      unversioned_name, = name.split("@")
      version_hash[unversioned_name] ||= Set.new
      version_hash[unversioned_name] << name
      next if version_hash[unversioned_name].length < 2

      version_conflict_deps += version_hash[unversioned_name]
    end

    [indirect_deps, undeclared_deps,
     unnecessary_deps, version_conflict_deps.to_a]
  end

  def sort_by_formula_full_name!(arr)
    arr.sort! do |a, b|
      if a.include?("/") && b.exclude?("/")
        1
      elsif a.exclude?("/") && b.include?("/")
        -1
      else
        a <=> b
      end
    end
  end

  # Whether or not dylib is a harmless broken link, meaning that it's
  # okay to skip (and not report) as broken.
  def harmless_broken_link?(dylib)
    # libgcc_s_* is referenced by programs that use the Java Service Wrapper,
    # and is harmless on x86(_64) machines
    return true if [
      "/usr/lib/libgcc_s_ppc64.1.dylib",
      "/opt/local/lib/libgcc/libgcc_s.1.dylib",
    ].include?(dylib)

    dylib.start_with?("/System/Library/Frameworks/")
  end

  # Display a list of things.
  # Things may either be an array, or a hash of (label -> array).
  def display_items(label, things, puts_output: true)
    return if things.empty?

    output = "#{label}:"
    if things.is_a? Hash
      things.keys.sort.each do |list_label|
        things[list_label].sort.each do |item|
          output += "\n  #{item} (#{list_label})"
        end
      end
    else
      things.sort.each do |item|
        output += if item.is_a? Regexp
          "\n  #{item.inspect}"
        else
          "\n  #{item}"
        end
      end
    end
    puts output if puts_output
    output
  end

  def resolve_formula(keg)
    Formulary.from_keg(keg)
  rescue FormulaUnavailableError
    opoo "Formula unavailable: #{keg.name}"
  end
end

require "extend/os/linkage_checker"
