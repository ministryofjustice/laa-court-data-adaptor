# typed: false
# frozen_string_literal: true

module Stdenv
  # @private

  undef homebrew_extra_pkg_config_paths, x11

  def homebrew_extra_pkg_config_paths
    ["#{HOMEBREW_LIBRARY}/Homebrew/os/mac/pkgconfig/#{MacOS.sdk_version}"]
  end

  def x11
    # There are some config scripts here that should go in the PATH
    append_path "PATH", MacOS::XQuartz.bin.to_s

    # Append these to PKG_CONFIG_LIBDIR so they are searched
    # *after* our own pkgconfig directories, as we dupe some of the
    # libs in XQuartz.
    append_path "PKG_CONFIG_LIBDIR", "#{MacOS::XQuartz.lib}/pkgconfig"
    append_path "PKG_CONFIG_LIBDIR", "#{MacOS::XQuartz.share}/pkgconfig"

    append "LDFLAGS", "-L#{MacOS::XQuartz.lib}"
    append_path "CMAKE_PREFIX_PATH", MacOS::XQuartz.prefix.to_s
    append_path "CMAKE_INCLUDE_PATH", MacOS::XQuartz.include.to_s
    append_path "CMAKE_INCLUDE_PATH", "#{MacOS::XQuartz.include}/freetype2"

    append "CPPFLAGS", "-I#{MacOS::XQuartz.include}"
    append "CPPFLAGS", "-I#{MacOS::XQuartz.include}/freetype2"

    append_path "ACLOCAL_PATH", "#{MacOS::XQuartz.share}/aclocal"

    append "CFLAGS", "-I#{MacOS::XQuartz.include}" unless MacOS::CLT.installed?
  end

  def setup_build_environment(**options)
    generic_setup_build_environment(**options)

    # sed is strict, and errors out when it encounters files with
    # mixed character sets
    delete("LC_ALL")
    self["LC_CTYPE"] = "C"

    # Add lib and include etc. from the current macosxsdk to compiler flags:
    macosxsdk(formula: @formula)

    return unless MacOS::Xcode.without_clt?

    append_path "PATH", "#{MacOS::Xcode.prefix}/usr/bin"
    append_path "PATH", "#{MacOS::Xcode.toolchain_path}/usr/bin"
  end

  def remove_macosxsdk(version = nil)
    # Clear all lib and include dirs from CFLAGS, CPPFLAGS, LDFLAGS that were
    # previously added by macosxsdk
    remove_from_cflags(/ ?-mmacosx-version-min=\d+\.\d+/)
    delete("CPATH")
    remove "LDFLAGS", "-L#{HOMEBREW_PREFIX}/lib"

    sdk = self["SDKROOT"] || MacOS.sdk_path_if_needed(version)
    return unless sdk

    delete("SDKROOT")
    remove_from_cflags "-isysroot#{sdk}"
    remove "CPPFLAGS", "-isysroot#{sdk}"
    remove "LDFLAGS", "-isysroot#{sdk}"
    if HOMEBREW_PREFIX.to_s == "/usr/local"
      delete("CMAKE_PREFIX_PATH")
    else
      # It was set in setup_build_environment, so we have to restore it here.
      self["CMAKE_PREFIX_PATH"] = HOMEBREW_PREFIX.to_s
    end
    remove "CMAKE_FRAMEWORK_PATH", "#{sdk}/System/Library/Frameworks"
  end

  def macosxsdk(version = nil, formula: nil)
    # Sets all needed lib and include dirs to CFLAGS, CPPFLAGS, LDFLAGS.
    remove_macosxsdk
    min_version = version || MacOS.version
    append_to_cflags("-mmacosx-version-min=#{min_version}")
    self["CPATH"] = "#{HOMEBREW_PREFIX}/include"
    prepend "LDFLAGS", "-L#{HOMEBREW_PREFIX}/lib"

    sdk = formula ? MacOS.sdk_for_formula(formula, version) : MacOS.sdk(version)
    return if !MacOS.sdk_root_needed? && sdk&.source != :xcode

    Homebrew::Diagnostic.checks(:fatal_setup_build_environment_checks)
    sdk = sdk.path

    # Extra setup to support Xcode 4.3+ without CLT.
    self["SDKROOT"] = sdk
    # Tell clang/gcc where system include's are:
    append_path "CPATH", "#{sdk}/usr/include"
    # The -isysroot is needed, too, because of the Frameworks
    append_to_cflags "-isysroot#{sdk}"
    append "CPPFLAGS", "-isysroot#{sdk}"
    # And the linker needs to find sdk/usr/lib
    append "LDFLAGS", "-isysroot#{sdk}"
    # Needed to build cmake itself and perhaps some cmake projects:
    append_path "CMAKE_PREFIX_PATH", "#{sdk}/usr"
    append_path "CMAKE_FRAMEWORK_PATH", "#{sdk}/System/Library/Frameworks"
  end

  # Some configure scripts won't find libxml2 without help.
  # This is a no-op with macOS SDK 10.15.4 and later.
  def libxml2
    sdk = self["SDKROOT"] || MacOS.sdk_path_if_needed
    if !sdk
      append "CPPFLAGS", "-I/usr/include/libxml2"
    elsif !Pathname("#{sdk}/usr/include/libxml").directory?
      # Use the includes form the sdk
      append "CPPFLAGS", "-I#{sdk}/usr/include/libxml2"
    end
  end

  def no_weak_imports
    append "LDFLAGS", "-Wl,-no_weak_imports" if no_weak_imports_support?
  end
end
