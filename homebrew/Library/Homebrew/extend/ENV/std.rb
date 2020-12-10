# typed: strict
# frozen_string_literal: true

require "hardware"
require "extend/ENV/shared"

# @private
module Stdenv
  extend T::Sig

  include SharedEnvExtension

  # @private
  SAFE_CFLAGS_FLAGS = "-w -pipe"

  # @private
  sig do
    params(
      formula:      T.nilable(Formula),
      cc:           T.nilable(String),
      build_bottle: T.nilable(T::Boolean),
      bottle_arch:  T.nilable(T::Boolean),
    ).void
  end
  def setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil)
    super

    self["HOMEBREW_ENV"] = "std"

    PATH.new(ENV["HOMEBREW_PATH"]).each { |p| prepend_path "PATH", p }

    # Set the default pkg-config search path, overriding the built-in paths
    # Anything in PKG_CONFIG_PATH is searched before paths in this variable
    self["PKG_CONFIG_LIBDIR"] = determine_pkg_config_libdir

    self["MAKEFLAGS"] = "-j#{make_jobs}"

    unless HOMEBREW_PREFIX.to_s == "/usr/local"
      # /usr/local is already an -isystem and -L directory so we skip it
      self["CPPFLAGS"] = "-isystem#{HOMEBREW_PREFIX}/include"
      self["LDFLAGS"] = "-L#{HOMEBREW_PREFIX}/lib"
      # CMake ignores the variables above
      self["CMAKE_PREFIX_PATH"] = HOMEBREW_PREFIX.to_s
    end

    frameworks = HOMEBREW_PREFIX.join("Frameworks")
    if frameworks.directory?
      append "CPPFLAGS", "-F#{frameworks}"
      append "LDFLAGS", "-F#{frameworks}"
      self["CMAKE_FRAMEWORK_PATH"] = frameworks.to_s
    end

    # Os is the default Apple uses for all its stuff so let's trust them
    define_cflags "-Os #{SAFE_CFLAGS_FLAGS}"

    append "LDFLAGS", "-Wl,-headerpad_max_install_names"

    send(compiler)

    return unless cc&.match?(GNU_GCC_REGEXP)

    gcc_formula = gcc_version_formula(cc)
    append_path "PATH", gcc_formula.opt_bin.to_s
  end
  alias generic_setup_build_environment setup_build_environment

  sig { returns(T::Array[Pathname]) }
  def homebrew_extra_pkg_config_paths
    []
  end

  sig { returns(T.nilable(PATH)) }
  def determine_pkg_config_libdir
    PATH.new(
      HOMEBREW_PREFIX/"lib/pkgconfig",
      HOMEBREW_PREFIX/"share/pkgconfig",
      homebrew_extra_pkg_config_paths,
      "/usr/lib/pkgconfig",
    ).existing
  end

  # Removes the MAKEFLAGS environment variable, causing make to use a single job.
  # This is useful for makefiles with race conditions.
  # When passed a block, MAKEFLAGS is removed only for the duration of the block and is restored after its completion.
  sig { params(block: T.proc.returns(T.untyped)).returns(T.untyped) }
  def deparallelize(&block)
    old = self["MAKEFLAGS"]
    remove "MAKEFLAGS", /-j\d+/
    if block
      begin
        yield
      ensure
        self["MAKEFLAGS"] = old
      end
    end

    old
  end

  %w[O3 O2 O1 O0 Os].each do |opt|
    define_method opt do
      send(:remove_from_cflags, /-O./)
      send(:append_to_cflags, "-#{opt}")
    end
  end

  sig { returns(T.any(String, Pathname)) }
  def determine_cc
    s = super
    DevelopmentTools.locate(s) || Pathname(s)
  end
  private :determine_cc

  sig { returns(Pathname) }
  def determine_cxx
    dir, base = Pathname(determine_cc).split
    dir/base.to_s.sub("gcc", "g++").sub("clang", "clang++")
  end
  private :determine_cxx

  GNU_GCC_VERSIONS.each do |n|
    define_method(:"gcc-#{n}") do
      super()
      send(:set_cpu_cflags)
    end
  end

  sig { void }
  def clang
    super()
    replace_in_cflags(/-Xarch_#{Hardware::CPU.arch_32_bit} (-march=\S*)/, '\1')
    map = Hardware::CPU.optimization_flags.dup
    if DevelopmentTools.clang_build_version < 700
      # Clang mistakenly enables AES-NI on plain Nehalem
      map[:nehalem] = "-march=nehalem -Xclang -target-feature -Xclang -aes"
    end
    set_cpu_cflags(map)
  end

  sig { void }
  def m64
    append_to_cflags "-m64"
    append "LDFLAGS", "-arch #{Hardware::CPU.arch_64_bit}"
  end

  sig { void }
  def m32
    append_to_cflags "-m32"
    append "LDFLAGS", "-arch #{Hardware::CPU.arch_32_bit}"
  end

  sig { void }
  def universal_binary
    check_for_compiler_universal_support

    append_to_cflags Hardware::CPU.universal_archs.as_arch_flags
    append "LDFLAGS", Hardware::CPU.universal_archs.as_arch_flags

    return if compiler_any_clang?
    return unless Hardware::CPU.is_32_bit?

    # Can't mix "-march" for a 32-bit CPU with "-arch x86_64"
    replace_in_cflags(/-march=\S*/, "-Xarch_#{Hardware::CPU.arch_32_bit} \\0")
  end

  sig { void }
  def cxx11
    append "CXX", "-std=c++11"
    libcxx
  end

  sig { void }
  def libcxx
    append "CXX", "-stdlib=libc++" if compiler == :clang
  end

  sig { void }
  def libstdcxx
    append "CXX", "-stdlib=libstdc++" if compiler == :clang
  end

  # @private
  sig { params(before: Regexp, after: String).void }
  def replace_in_cflags(before, after)
    CC_FLAG_VARS.each do |key|
      self[key] = fetch(key).sub(before, after) if key?(key)
    end
  end

  # Convenience method to set all C compiler flags in one shot.
  sig { params(val: String).void }
  def define_cflags(val)
    CC_FLAG_VARS.each { |key| self[key] = val }
  end

  # Sets architecture-specific flags for every environment variable
  # given in the list `flags`.
  # @private
  sig { params(flags: T::Array[String], map: T::Hash[Symbol, String]).void }
  def set_cpu_flags(flags, map = Hardware::CPU.optimization_flags)
    cflags =~ /(-Xarch_#{Hardware::CPU.arch_32_bit} )-march=/
    xarch = Regexp.last_match(1).to_s
    remove flags, /(-Xarch_#{Hardware::CPU.arch_32_bit} )?-march=\S*/
    remove flags, /( -Xclang \S+)+/
    remove flags, /-mssse3/
    remove flags, /-msse4(\.\d)?/
    append flags, xarch unless xarch.empty?
    append flags, map.fetch(effective_arch)
  end

  sig { void }
  def x11; end

  # @private
  sig { params(map: T::Hash[Symbol, String]).void }
  def set_cpu_cflags(map = Hardware::CPU.optimization_flags) # rubocop:disable Naming/AccessorMethodName
    set_cpu_flags(CC_FLAG_VARS, map)
  end

  sig { returns(Integer) }
  def make_jobs
    Homebrew::EnvConfig.make_jobs.to_i
  end

  # This method does nothing in stdenv since there's no arg refurbishment
  # @private
  sig { void }
  def refurbish_args; end
end

require "extend/os/extend/ENV/std"
