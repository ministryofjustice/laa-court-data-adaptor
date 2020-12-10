# typed: strict
# frozen_string_literal: true

require "system_command"

module UnpackStrategy
  class Zip
    module MacOSZipExtension
      extend T::Sig

      include UnpackStrategy
      include SystemCommand::Mixin

      using Magic

      sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).returns(T.untyped) }
      def extract_to_dir(unpack_dir, basename:, verbose:)
        if merge_xattrs && contains_extended_attributes?(path)
          # We use ditto directly, because dot_clean has issues if the __MACOSX
          # folder has incorrect permissions.
          # (Also, Homebrew's ZIP artifact automatically deletes this folder.)
          return system_command! "ditto",
                                 args:         ["-x", "-k", path, unpack_dir],
                                 verbose:      verbose,
                                 print_stderr: false
        end

        result = begin
          T.let(super, T.nilable(SystemCommand::Result))
        rescue ErrorDuringExecution => e
          raise unless e.stderr.include?("End-of-central-directory signature not found.")

          system_command! "ditto",
                          args:    ["-x", "-k", path, unpack_dir],
                          verbose: verbose
          nil
        end

        return if result.blank?

        volumes = result.stderr.chomp
                        .split("\n")
                        .map { |l| l[/\A   skipping: (.+)  volume label\Z/, 1] }
                        .compact

        return if volumes.empty?

        Dir.mktmpdir do |tmp_unpack_dir|
          tmp_unpack_dir = Pathname(tmp_unpack_dir)

          # `ditto` keeps Finder attributes intact and does not skip volume labels
          # like `unzip` does, which can prevent disk images from being unzipped.
          system_command! "ditto",
                          args:    ["-x", "-k", path, tmp_unpack_dir],
                          verbose: verbose

          volumes.each do |volume|
            FileUtils.mv tmp_unpack_dir/volume, unpack_dir/volume, verbose: verbose
          end
        end
      end

      private

      sig { params(path: Pathname).returns(T::Boolean) }
      def contains_extended_attributes?(path)
        path.zipinfo.grep(/(^__MACOSX|\._)/).any?
      end
    end
    private_constant :MacOSZipExtension

    prepend MacOSZipExtension
  end
end
