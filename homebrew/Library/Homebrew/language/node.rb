# typed: true
# frozen_string_literal: true

module Language
  # Helper functions for Node formulae.
  #
  # @api public
  module Node
    extend T::Sig

    sig { returns(String) }
    def self.npm_cache_config
      "cache=#{HOMEBREW_CACHE}/npm_cache"
    end

    def self.pack_for_installation
      # Homebrew assumes the buildpath/testpath will always be disposable
      # and from npm 5.0.0 the logic changed so that when a directory is
      # fed to `npm install` only symlinks are created linking back to that
      # directory, consequently breaking that assumption. We require a tarball
      # because npm install creates a "real" installation when fed a tarball.
      if (package = Pathname("package.json")) && package.exist?
        begin
          pkg_json = JSON.parse(package.read)
        rescue JSON::ParserError
          opoo "Could not parse package.json!"
          raise
        end
        prepare_removed = pkg_json["scripts"]&.delete("prepare")
        prepack_removed = pkg_json["scripts"]&.delete("prepack")
        package.atomic_write(JSON.pretty_generate(pkg_json)) if prepare_removed || prepack_removed
      end
      output = Utils.popen_read("npm pack --ignore-scripts")
      raise "npm failed to pack #{Dir.pwd}" if !$CHILD_STATUS.exitstatus.zero? || output.lines.empty?

      output.lines.last.chomp
    end

    def self.setup_npm_environment
      # guard that this is only run once
      return if @env_set

      @env_set = true
      # explicitly use our npm and node-gyp executables instead of the user
      # managed ones in HOMEBREW_PREFIX/lib/node_modules which might be broken
      begin
        ENV.prepend_path "PATH", Formula["node"].opt_libexec/"bin"
      rescue FormulaUnavailableError
        nil
      end
    end

    def self.std_npm_install_args(libexec)
      setup_npm_environment
      # tell npm to not install .brew_home by adding it to the .npmignore file
      # (or creating a new one if no .npmignore file already exists)
      open(".npmignore", "a") { |f| f.write("\n.brew_home\n") }

      pack = pack_for_installation

      # npm 7 requires that these dirs exist before install
      (libexec/"lib").mkpath

      # npm install args for global style module format installed into libexec
      args = %W[
        -ddd
        --global
        --build-from-source
        --#{npm_cache_config}
        --prefix=#{libexec}
        #{Dir.pwd}/#{pack}
      ]

      args << "--unsafe-perm" if Process.uid.zero?

      args
    end

    sig { returns(T::Array[String]) }
    def self.local_npm_install_args
      setup_npm_environment
      # npm install args for local style module format
      %W[
        -ddd
        --build-from-source
        --#{npm_cache_config}
      ]
    end
  end
end
