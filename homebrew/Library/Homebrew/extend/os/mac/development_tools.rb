# typed: true
# frozen_string_literal: true

require "os/mac/xcode"

# @private
class DevelopmentTools
  class << self
    extend T::Sig

    alias generic_locate locate
    undef installed?, default_compiler, curl_handles_most_https_certificates?,
          subversion_handles_most_https_certificates?

    def locate(tool)
      (@locate ||= {}).fetch(tool) do |key|
        @locate[key] = if (located_tool = generic_locate(tool))
          located_tool
        else
          path = Utils.popen_read("/usr/bin/xcrun", "-no-cache", "-find", tool, err: :close).chomp
          Pathname.new(path) if File.executable?(path)
        end
      end
    end

    # Checks if the user has any developer tools installed, either via Xcode
    # or the CLT. Convenient for guarding against formula builds when building
    # is impossible.
    def installed?
      MacOS::Xcode.installed? || MacOS::CLT.installed?
    end

    sig { returns(Symbol) }
    def default_compiler
      :clang
    end

    sig { returns(T::Boolean) }
    def curl_handles_most_https_certificates?
      # The system Curl is too old for some modern HTTPS certificates on
      # older macOS versions.
      ENV["HOMEBREW_SYSTEM_CURL_TOO_OLD"].nil?
    end

    sig { returns(T::Boolean) }
    def subversion_handles_most_https_certificates?
      # The system Subversion is too old for some HTTPS certificates on
      # older macOS versions.
      MacOS.version >= :sierra
    end

    sig { returns(String) }
    def installation_instructions
      <<~EOS
        Install the Command Line Tools:
          xcode-select --install
      EOS
    end

    sig { returns(String) }
    def custom_installation_instructions
      <<~EOS
        Install GNU's GCC:
          brew install gcc
      EOS
    end

    def build_system_info
      build_info = {
        "xcode" => MacOS::Xcode.version.to_s.presence,
        "clt"   => MacOS::CLT.version.to_s.presence,
      }
      generic_build_system_info.merge build_info
    end
  end
end
