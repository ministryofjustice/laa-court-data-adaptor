# typed: false
# frozen_string_literal: true

require "stringio"
require "formula"
require "cli/parser"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def unpack_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `unpack` [<options>] <formula>

        Unpack the source files for <formula> into subdirectories of the current
        working directory.
      EOS
      flag   "--destdir=",
             description: "Create subdirectories in the directory named by <path> instead."
      switch "--patch",
             description: "Patches for <formula> will be applied to the unpacked source."
      switch "-g", "--git",
             description: "Initialise a Git repository in the unpacked source. This is useful for creating "\
                          "patches for the software."
      switch "-f", "--force",
             description: "Overwrite the destination directory if it already exists."

      conflicts "--git", "--patch"
      min_named :formula
    end
  end

  def unpack
    args = unpack_args.parse

    formulae = args.named.to_formulae

    if dir = args.destdir
      unpack_dir = Pathname.new(dir).expand_path
      unpack_dir.mkpath
    else
      unpack_dir = Pathname.pwd
    end

    raise "Cannot write to #{unpack_dir}" unless unpack_dir.writable_real?

    formulae.each do |f|
      stage_dir = unpack_dir/"#{f.name}-#{f.version}"

      if stage_dir.exist?
        raise "Destination #{stage_dir} already exists!" unless args.force?

        rm_rf stage_dir
      end

      oh1 "Unpacking #{Formatter.identifier(f.full_name)} to: #{stage_dir}"

      # show messages about tar
      with_env VERBOSE: "1" do
        f.brew do
          f.patch if args.patch?
          cp_r getwd, stage_dir, preserve: true
        end
      end

      next unless args.git?

      ohai "Setting up git repository"
      cd stage_dir
      system "git", "init", "-q"
      system "git", "add", "-A"
      system "git", "commit", "-q", "-m", "brew-unpack"
    end
  end
end
