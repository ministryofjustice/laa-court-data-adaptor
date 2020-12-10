# typed: strict
# frozen_string_literal: true

module UnpackStrategy
  # Strategy for unpacking ZIP archives.
  class Zip
    extend T::Sig

    include UnpackStrategy

    using Magic

    sig { returns(T::Array[String]) }
    def self.extensions
      [".zip"]
    end

    sig { params(path: Pathname).returns(T::Boolean) }
    def self.can_extract?(path)
      path.magic_number.match?(/\APK(\003\004|\005\006)/n)
    end

    private

    sig do
      override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean)
              .returns(SystemCommand::Result)
    end
    def extract_to_dir(unpack_dir, basename:, verbose:)
      quiet_flags = verbose ? [] : ["-qq"]
      result = system_command! "unzip",
                               args:         [*quiet_flags, "-o", path, "-d", unpack_dir],
                               verbose:      verbose,
                               print_stderr: false

      FileUtils.rm_rf unpack_dir/"__MACOSX"

      result
    end
  end
end

require "extend/os/mac/unpack_strategy/zip" if OS.mac?
