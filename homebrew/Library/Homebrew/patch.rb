# typed: false
# frozen_string_literal: true

require "resource"
require "erb"

# Helper module for creating patches.
#
# @api private
module Patch
  def self.create(strip, src, &block)
    case strip
    when :DATA
      DATAPatch.new(:p1)
    when String
      StringPatch.new(:p1, strip)
    when Symbol
      case src
      when :DATA
        DATAPatch.new(strip)
      when String
        StringPatch.new(strip, src)
      else
        ExternalPatch.new(strip, &block)
      end
    when nil
      raise ArgumentError, "nil value for strip"
    else
      raise ArgumentError, "unexpected value #{strip.inspect} for strip"
    end
  end

  def self.normalize_legacy_patches(list)
    patches = []

    case list
    when Hash
      list
    when Array, String, :DATA
      { p1: list }
    else
      {}
    end.each_pair do |strip, urls|
      Array(urls).each do
        patches << DATAPatch.new(strip)
      end
    end

    patches
  end
end

# An abstract class representing a patch embedded into a formula.
#
# @api private
class EmbeddedPatch
  extend T::Sig

  attr_writer :owner
  attr_reader :strip

  def initialize(strip)
    @strip = strip
  end

  sig { returns(T::Boolean) }
  def external?
    false
  end

  def contents; end

  def apply
    data = contents.gsub("HOMEBREW_PREFIX", HOMEBREW_PREFIX)
    args = %W[-g 0 -f -#{strip}]
    Utils.safe_popen_write("patch", *args) { |p| p.write(data) }
  end

  sig { returns(String) }
  def inspect
    "#<#{self.class.name}: #{strip.inspect}>"
  end
end

# A patch at the `__END__` of a formula file.
#
# @api private
class DATAPatch < EmbeddedPatch
  extend T::Sig

  attr_accessor :path

  def initialize(strip)
    super
    @path = nil
  end

  sig { returns(String) }
  def contents
    data = +""
    path.open("rb") do |f|
      loop do
        line = f.gets
        break if line.nil? || line =~ /^__END__$/
      end
      while line = f.gets
        data << line
      end
    end
    data.freeze
  end
end

# A string containing a patch.
#
# @api private
class StringPatch < EmbeddedPatch
  def initialize(strip, str)
    super(strip)
    @str = str
  end

  def contents
    @str
  end
end

# A string containing a patch.
#
# @api private
class ExternalPatch
  extend T::Sig

  extend Forwardable

  attr_reader :resource, :strip

  def_delegators :resource,
                 :url, :fetch, :patch_files, :verify_download_integrity,
                 :cached_download, :downloaded?, :clear_cache

  def initialize(strip, &block)
    @strip    = strip
    @resource = Resource::PatchResource.new(&block)
  end

  sig { returns(T::Boolean) }
  def external?
    true
  end

  def owner=(owner)
    resource.owner   = owner
    resource.version = resource.checksum || ERB::Util.url_encode(resource.url)
  end

  def apply
    base_dir = Pathname.pwd
    resource.unpack do
      patch_dir = Pathname.pwd
      if patch_files.empty?
        children = patch_dir.children
        if children.length != 1 || !children.first.file?
          raise MissingApplyError, <<~EOS
            There should be exactly one patch file in the staging directory unless
            the "apply" method was used one or more times in the patch-do block.
          EOS
        end

        patch_files << children.first.basename
      end
      dir = base_dir
      dir /= resource.directory if resource.directory.present?
      dir.cd do
        patch_files.each do |patch_file|
          ohai "Applying #{patch_file}"
          patch_file = patch_dir/patch_file
          safe_system "patch", "-g", "0", "-f", "-#{strip}", "-i", patch_file
        end
      end
    end
  rescue ErrorDuringExecution => e
    f = resource.owner.owner
    cmd, *args = e.cmd
    raise BuildError.new(f, cmd, args, ENV.to_hash)
  end

  sig { returns(String) }
  def inspect
    "#<#{self.class.name}: #{strip.inspect} #{url.inspect}>"
  end
end
