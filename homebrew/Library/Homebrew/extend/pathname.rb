# typed: true
# frozen_string_literal: true

require "resource"
require "metafiles"

module DiskUsageExtension
  extend T::Sig

  sig { returns(Integer) }
  def disk_usage
    return @disk_usage if defined?(@disk_usage)

    compute_disk_usage
    @disk_usage
  end

  sig { returns(Integer) }
  def file_count
    return @file_count if defined?(@file_count)

    compute_disk_usage
    @file_count
  end

  sig { returns(String) }
  def abv
    out = +""
    compute_disk_usage
    out << "#{number_readable(@file_count)} files, " if @file_count > 1
    out << disk_usage_readable(@disk_usage).to_s
    out.freeze
  end

  private

  sig { void }
  def compute_disk_usage
    if symlink? && !exist?
      @file_count = 1
      @disk_usage = 0
      return
    end

    path = if symlink?
      resolved_path
    else
      self
    end

    if path.directory?
      scanned_files = Set.new
      @file_count = 0
      @disk_usage = 0
      path.find do |f|
        if f.directory?
          @disk_usage += f.lstat.size
        else
          @file_count += 1 if f.basename.to_s != ".DS_Store"
          # use Pathname#lstat instead of Pathname#stat to get info of symlink itself.
          stat = f.lstat
          file_id = [stat.dev, stat.ino]
          # count hardlinks only once.
          unless scanned_files.include?(file_id)
            @disk_usage += stat.size
            scanned_files.add(file_id)
          end
        end
      end
    else
      @file_count = 1
      @disk_usage = path.lstat.size
    end
  end
end

# Homebrew extends Ruby's `Pathname` to make our code more readable.
# @see https://ruby-doc.org/stdlib-2.6.3/libdoc/pathname/rdoc/Pathname.html Ruby's Pathname API
class Pathname
  extend T::Sig

  include DiskUsageExtension

  # @private
  BOTTLE_EXTNAME_RX = /(\.[a-z0-9_]+\.bottle\.(\d+\.)?tar\.gz)$/.freeze

  # Moves a file from the original location to the {Pathname}'s.
  sig do
    params(sources: T.any(
      Resource, Resource::Partial, String, Pathname,
      T::Array[T.any(String, Pathname)], T::Hash[T.any(String, Pathname), String]
    )).void
  end
  def install(*sources)
    sources.each do |src|
      case src
      when Resource
        src.stage(self)
      when Resource::Partial
        src.resource.stage { install(*src.files) }
      when Array
        if src.empty?
          opoo "tried to install empty array to #{self}"
          break
        end
        src.each { |s| install_p(s, File.basename(s)) }
      when Hash
        if src.empty?
          opoo "tried to install empty hash to #{self}"
          break
        end
        src.each { |s, new_basename| install_p(s, new_basename) }
      else
        install_p(src, File.basename(src))
      end
    end
  end

  sig { params(src: T.any(String, Pathname), new_basename: String).void }
  def install_p(src, new_basename)
    raise Errno::ENOENT, src.to_s unless File.symlink?(src) || File.exist?(src)

    src = Pathname(src)
    dst = join(new_basename)
    dst = yield(src, dst) if block_given?
    return unless dst

    mkpath

    # Use FileUtils.mv over File.rename to handle filesystem boundaries. If src
    # is a symlink, and its target is moved first, FileUtils.mv will fail:
    #   https://bugs.ruby-lang.org/issues/7707
    # In that case, use the system "mv" command.
    if src.symlink?
      raise unless Kernel.system "mv", src, dst
    else
      FileUtils.mv src, dst
    end
  end
  private :install_p

  # Creates symlinks to sources in this folder.
  sig do
    params(
      sources: T.any(String, Pathname, T::Array[T.any(String, Pathname)], T::Hash[T.any(String, Pathname), String]),
    ).void
  end
  def install_symlink(*sources)
    sources.each do |src|
      case src
      when Array
        src.each { |s| install_symlink_p(s, File.basename(s)) }
      when Hash
        src.each { |s, new_basename| install_symlink_p(s, new_basename) }
      else
        install_symlink_p(src, File.basename(src))
      end
    end
  end

  def install_symlink_p(src, new_basename)
    mkpath
    dstdir = realpath
    src = Pathname(src).expand_path(dstdir)
    src = src.dirname.realpath/src.basename if src.dirname.exist?
    FileUtils.ln_sf(src.relative_path_from(dstdir), dstdir/new_basename)
  end
  private :install_symlink_p

  # @private
  alias old_write write

  # We assume this pathname object is a file, obviously.
  sig { params(content: String, offset: Integer, open_args: T::Hash[Symbol, T.untyped]).returns(Integer) }
  def write(content, offset = 0, open_args = {})
    raise "Will not overwrite #{self}" if exist?

    dirname.mkpath

    old_write(content, offset, open_args)
  end

  # Only appends to a file that is already created.
  sig { params(content: String, open_args: T.untyped).void }
  def append_lines(content, **open_args)
    raise "Cannot append file that doesn't exist: #{self}" unless exist?

    T.unsafe(self).open("a", **open_args) { |f| f.puts(content) }
  end

  # @note This always overwrites.
  sig { params(content: String).void }
  def atomic_write(content)
    old_stat = stat if exist?
    File.atomic_write(self) do |file|
      file.write(content)
    end

    return unless old_stat

    # Try to restore original file's permissions separately
    # atomic_write does it itself, but it actually erases
    # them if chown fails
    begin
      # Set correct permissions on new file
      chown(old_stat.uid, nil)
      chown(nil, old_stat.gid)
    rescue Errno::EPERM, Errno::EACCES
      # Changing file ownership failed, moving on.
      nil
    end
    begin
      # This operation will affect filesystem ACL's
      chmod(old_stat.mode)
    rescue Errno::EPERM, Errno::EACCES
      # Changing file permissions failed, moving on.
      nil
    end
  end

  # @private
  def cp_path_sub(pattern, replacement)
    raise "#{self} does not exist" unless exist?

    dst = sub(pattern, replacement)

    raise "#{self} is the same file as #{dst}" if self == dst

    if directory?
      dst.mkpath
    else
      dst.dirname.mkpath
      dst = yield(self, dst) if block_given?
      FileUtils.cp(self, dst)
    end
  end

  # @private
  alias extname_old extname

  # Extended to support common double extensions.
  sig { returns(String) }
  def extname
    basename = File.basename(self)

    bottle_ext = basename[BOTTLE_EXTNAME_RX, 1]
    return bottle_ext if bottle_ext

    archive_ext = basename[/(\.(tar|cpio|pax)\.(gz|bz2|lz|xz|Z))\Z/, 1]
    return archive_ext if archive_ext

    # Don't treat version numbers as extname.
    return "" if basename.match?(/\b\d+\.\d+[^.]*\Z/) && !basename.end_with?(".7z")

    File.extname(basename)
  end

  # For filetypes we support, returns basename without extension.
  sig { returns(String) }
  def stem
    File.basename(self, extname)
  end

  # I don't trust the children.length == 0 check particularly, not to mention
  # it is slow to enumerate the whole directory just to see if it is empty,
  # instead rely on good ol' libc and the filesystem
  # @private
  sig { returns(T::Boolean) }
  def rmdir_if_possible
    rmdir
    true
  rescue Errno::ENOTEMPTY
    if (ds_store = join(".DS_Store")).exist? && children.length == 1
      ds_store.unlink
      retry
    else
      false
    end
  rescue Errno::EACCES, Errno::ENOENT, Errno::EBUSY
    false
  end

  # @private
  sig { returns(Version) }
  def version
    require "version"
    Version.parse(basename)
  end

  # @private
  sig { returns(T::Boolean) }
  def text_executable?
    /^#!\s*\S+/.match?(open("r") { |f| f.read(1024) })
  end

  sig { returns(String) }
  def sha256
    require "digest/sha2"
    Digest::SHA256.file(self).hexdigest
  end

  sig { params(expected: T.nilable(Checksum)).void }
  def verify_checksum(expected)
    raise ChecksumMissingError if expected.blank?

    actual = Checksum.new(expected.hash_type, send(expected.hash_type).downcase)
    raise ChecksumMismatchError.new(self, expected, actual) unless expected == actual
  end

  alias to_str to_s

  sig do
    type_parameters(:U).params(
      _block: T.proc.params(path: Pathname).returns(T.type_parameter(:U)),
    ).returns(T.type_parameter(:U))
  end
  def cd(&_block)
    Dir.chdir(self) { yield self }
  end

  sig { returns(T::Array[Pathname]) }
  def subdirs
    children.select(&:directory?)
  end

  # @private
  sig { returns(Pathname) }
  def resolved_path
    symlink? ? dirname.join(readlink) : self
  end

  # @private
  sig { returns(T::Boolean) }
  def resolved_path_exists?
    link = readlink
  rescue ArgumentError
    # The link target contains NUL bytes
    false
  else
    dirname.join(link).exist?
  end

  # @private
  def make_relative_symlink(src)
    dirname.mkpath
    File.symlink(src.relative_path_from(dirname), self)
  end

  # @private
  def ensure_writable
    saved_perms = nil
    unless writable_real?
      saved_perms = stat.mode
      FileUtils.chmod "u+rw", to_path
    end
    yield
  ensure
    chmod saved_perms if saved_perms
  end

  # @private
  def install_info
    quiet_system "/usr/bin/install-info", "--quiet", to_s, "#{dirname}/dir"
  end

  # @private
  def uninstall_info
    quiet_system "/usr/bin/install-info", "--delete", "--quiet", to_s, "#{dirname}/dir"
  end

  # Writes an exec script in this folder for each target pathname.
  def write_exec_script(*targets)
    targets.flatten!
    if targets.empty?
      opoo "tried to write exec scripts to #{self} for an empty list of targets"
      return
    end
    mkpath
    targets.each do |target|
      target = Pathname.new(target) # allow pathnames or strings
      join(target.basename).write <<~SH
        #!/bin/bash
        exec "#{target}" "$@"
      SH
    end
  end

  # Writes an exec script that sets environment variables.
  def write_env_script(target, args, env = nil)
    unless env
      env = args
      args = nil
    end
    env_export = +""
    env.each { |key, value| env_export << "#{key}=\"#{value}\" " }
    dirname.mkpath
    write <<~SH
      #!/bin/bash
      #{env_export}exec "#{target}" #{args} "$@"
    SH
  end

  # Writes a wrapper env script and moves all files to the dst.
  def env_script_all_files(dst, env)
    dst.mkpath
    Pathname.glob("#{self}/*") do |file|
      next if file.directory?

      dst.install(file)
      new_file = dst.join(file.basename)
      file.write_env_script(new_file, env)
    end
  end

  # Writes an exec script that invokes a Java jar.
  sig do
    params(
      target_jar:   T.any(String, Pathname),
      script_name:  T.any(String, Pathname),
      java_opts:    String,
      java_version: T.nilable(String),
    ).returns(Integer)
  end
  def write_jar_script(target_jar, script_name, java_opts = "", java_version: nil)
    (self/script_name).write <<~EOS
      #!/bin/bash
      export JAVA_HOME="#{Language::Java.overridable_java_home_env(java_version)[:JAVA_HOME]}"
      exec "${JAVA_HOME}/bin/java" #{java_opts} -jar "#{target_jar}" "$@"
    EOS
  end

  def install_metafiles(from = Pathname.pwd)
    Pathname(from).children.each do |p|
      next if p.directory?
      next unless Metafiles.copy?(p.basename.to_s)

      # Some software symlinks these files (see help2man.rb)
      filename = p.resolved_path
      # Some software links metafiles together, so by the time we iterate to one of them
      # we may have already moved it. libxml2's COPYING and Copyright are affected by this.
      next unless filename.exist?

      filename.chmod 0644
      install(filename)
    end
  end

  sig { returns(T::Boolean) }
  def ds_store?
    basename.to_s == ".DS_Store"
  end

  sig { returns(T::Boolean) }
  def binary_executable?
    false
  end

  sig { returns(T::Boolean) }
  def mach_o_bundle?
    false
  end

  sig { returns(T::Boolean) }
  def dylib?
    false
  end
end

require "extend/os/pathname"

# @private
module ObserverPathnameExtension
  extend T::Sig

  class << self
    extend T::Sig

    include Context

    sig { returns(Integer) }
    attr_accessor :n, :d

    sig { void }
    def reset_counts!
      @n = @d = 0
      @put_verbose_trimmed_warning = false
    end

    sig { returns(Integer) }
    def total
      n + d
    end

    sig { returns([Integer, Integer]) }

    def counts
      [n, d]
    end

    MAXIMUM_VERBOSE_OUTPUT = 100
    private_constant :MAXIMUM_VERBOSE_OUTPUT

    sig { returns(T::Boolean) }
    def verbose?
      return super unless ENV["CI"]
      return false unless super

      if total < MAXIMUM_VERBOSE_OUTPUT
        true
      else
        unless @put_verbose_trimmed_warning
          puts "Only the first #{MAXIMUM_VERBOSE_OUTPUT} operations were output."
          @put_verbose_trimmed_warning = true
        end
        false
      end
    end
  end

  sig { void }
  def unlink
    super
    puts "rm #{self}" if ObserverPathnameExtension.verbose?
    ObserverPathnameExtension.n += 1
  end

  sig { void }
  def mkpath
    super
    puts "mkdir -p #{self}" if ObserverPathnameExtension.verbose?
  end

  sig { void }
  def rmdir
    super
    puts "rmdir #{self}" if ObserverPathnameExtension.verbose?
    ObserverPathnameExtension.d += 1
  end

  sig { params(src: Pathname).void }
  def make_relative_symlink(src)
    super
    puts "ln -s #{src.relative_path_from(dirname)} #{basename}" if ObserverPathnameExtension.verbose?
    ObserverPathnameExtension.n += 1
  end

  sig { void }
  def install_info
    super
    puts "info #{self}" if ObserverPathnameExtension.verbose?
  end

  sig { void }
  def uninstall_info
    super
    puts "uninfo #{self}" if ObserverPathnameExtension.verbose?
  end
end
