# typed: false
# frozen_string_literal: true

require "system_command"

# Module containing all available strategies for unpacking archives.
#
# @api private
module UnpackStrategy
  extend T::Sig
  extend T::Helpers

  include SystemCommand::Mixin

  # Helper module for identifying the file type.
  module Magic
    # Length of the longest regex (currently Tar).
    MAX_MAGIC_NUMBER_LENGTH = 262
    private_constant :MAX_MAGIC_NUMBER_LENGTH

    refine Pathname do
      def magic_number
        @magic_number ||= if directory?
          ""
        else
          binread(MAX_MAGIC_NUMBER_LENGTH) || ""
        end
      end

      def file_type
        @file_type ||= system_command("file", args: ["-b", self], print_stderr: false)
                       .stdout.chomp
      end

      def zipinfo
        @zipinfo ||= system_command("zipinfo", args: ["-1", self], print_stderr: false)
                     .stdout
                     .encode(Encoding::UTF_8, invalid: :replace)
                     .split("\n")
      end
    end
  end
  private_constant :Magic

  def self.strategies
    @strategies ||= [
      Tar, # Needs to be before Bzip2/Gzip/Xz/Lzma.
      Pax,
      Gzip,
      Dmg, # Needs to be before Bzip2/Xz/Lzma.
      Lzma,
      Xz,
      Lzip,
      Air, # Needs to be before `Zip`.
      Jar, # Needs to be before `Zip`.
      LuaRock, # Needs to be before `Zip`.
      MicrosoftOfficeXml, # Needs to be before `Zip`.
      Zip,
      Pkg, # Needs to be before `Xar`.
      Xar,
      Ttf,
      Otf,
      Git,
      Mercurial,
      Subversion,
      Cvs,
      SelfExtractingExecutable, # Needs to be before `Cab`.
      Cab,
      Executable,
      Bzip2,
      Fossil,
      Bazaar,
      Compress,
      P7Zip,
      Sit,
      Rar,
      Lha,
    ].freeze
  end
  private_class_method :strategies

  def self.from_type(type)
    type = {
      naked:     :uncompressed,
      nounzip:   :uncompressed,
      seven_zip: :p7zip,
    }.fetch(type, type)

    begin
      const_get(type.to_s.split("_").map(&:capitalize).join.gsub(/\d+[a-z]/, &:upcase))
    rescue NameError
      nil
    end
  end

  def self.from_extension(extension)
    strategies.sort_by { |s| s.extensions.map(&:length).max || 0 }
              .reverse
              .find { |s| s.extensions.any? { |ext| extension.end_with?(ext) } }
  end

  def self.from_magic(path)
    strategies.find { |s| s.can_extract?(path) }
  end

  def self.detect(path, prioritise_extension: false, type: nil, ref_type: nil, ref: nil, merge_xattrs: nil)
    strategy = from_type(type) if type

    if prioritise_extension && path.extname.present?
      strategy ||= from_extension(path.extname)
      strategy ||= strategies.select { |s| s < Directory || s == Fossil }
                             .find { |s| s.can_extract?(path) }
    else
      strategy ||= from_magic(path)
      strategy ||= from_extension(path.extname)
    end

    strategy ||= Uncompressed

    strategy.new(path, ref_type: ref_type, ref: ref, merge_xattrs: merge_xattrs)
  end

  attr_reader :path, :merge_xattrs

  def initialize(path, ref_type: nil, ref: nil, merge_xattrs: nil)
    @path = Pathname(path).expand_path
    @ref_type = ref_type
    @ref = ref
    @merge_xattrs = merge_xattrs
  end

  abstract!
  sig { abstract.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).returns(T.untyped) }
  def extract_to_dir(unpack_dir, basename:, verbose:); end
  private :extract_to_dir

  def extract(to: nil, basename: nil, verbose: nil)
    basename ||= path.basename
    unpack_dir = Pathname(to || Dir.pwd).expand_path
    unpack_dir.mkpath
    extract_to_dir(unpack_dir, basename: Pathname(basename), verbose: verbose || false)
  end

  def extract_nestedly(to: nil, basename: nil, verbose: false, prioritise_extension: false)
    Dir.mktmpdir do |tmp_unpack_dir|
      tmp_unpack_dir = Pathname(tmp_unpack_dir)

      extract(to: tmp_unpack_dir, basename: basename, verbose: verbose)

      children = tmp_unpack_dir.children

      if children.count == 1 && !children.first.directory?
        FileUtils.chmod "+rw", children.first, verbose: verbose

        s = UnpackStrategy.detect(children.first, prioritise_extension: prioritise_extension)

        s.extract_nestedly(to: to, verbose: verbose, prioritise_extension: prioritise_extension)
        next
      end

      Directory.new(tmp_unpack_dir).extract(to: to, verbose: verbose)

      FileUtils.chmod_R "+w", tmp_unpack_dir, force: true, verbose: verbose
    end
  end

  def dependencies
    []
  end
end

require "unpack_strategy/air"
require "unpack_strategy/bazaar"
require "unpack_strategy/bzip2"
require "unpack_strategy/cab"
require "unpack_strategy/compress"
require "unpack_strategy/cvs"
require "unpack_strategy/directory"
require "unpack_strategy/dmg"
require "unpack_strategy/executable"
require "unpack_strategy/fossil"
require "unpack_strategy/generic_unar"
require "unpack_strategy/git"
require "unpack_strategy/gzip"
require "unpack_strategy/jar"
require "unpack_strategy/lha"
require "unpack_strategy/lua_rock"
require "unpack_strategy/lzip"
require "unpack_strategy/lzma"
require "unpack_strategy/mercurial"
require "unpack_strategy/microsoft_office_xml"
require "unpack_strategy/otf"
require "unpack_strategy/p7zip"
require "unpack_strategy/pax"
require "unpack_strategy/pkg"
require "unpack_strategy/rar"
require "unpack_strategy/self_extracting_executable"
require "unpack_strategy/sit"
require "unpack_strategy/subversion"
require "unpack_strategy/tar"
require "unpack_strategy/ttf"
require "unpack_strategy/uncompressed"
require "unpack_strategy/xar"
require "unpack_strategy/xz"
require "unpack_strategy/zip"
