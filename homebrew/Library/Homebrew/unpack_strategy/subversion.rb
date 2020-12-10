# typed: true
# frozen_string_literal: true

require_relative "directory"

module UnpackStrategy
  # Strategy for unpacking Subversion repositories.
  class Subversion < Directory
    using Magic

    def self.can_extract?(path)
      super && (path/".svn").directory?
    end

    private

    def extract_to_dir(unpack_dir, basename:, verbose:)
      system_command! "svn",
                      args:    ["export", "--force", ".", unpack_dir],
                      chdir:   path.to_s,
                      verbose: verbose
    end
  end
end
