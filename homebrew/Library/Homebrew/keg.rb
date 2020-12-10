# typed: false
# frozen_string_literal: true

require "keg_relocate"
require "language/python"
require "lock_file"
require "ostruct"
require "extend/cachable"

# Installation prefix of a formula.
#
# @api private
class Keg
  extend T::Sig

  extend Cachable

  # Error for when a keg is already linked.
  class AlreadyLinkedError < RuntimeError
    def initialize(keg)
      super <<~EOS
        Cannot link #{keg.name}
        Another version is already linked: #{keg.linked_keg_record.resolved_path}
      EOS
    end
  end

  # Error for when a keg cannot be linked.
  class LinkError < RuntimeError
    attr_reader :keg, :src, :dst

    def initialize(keg, src, dst, cause)
      @src = src
      @dst = dst
      @keg = keg
      @cause = cause
      super(cause.message)
      set_backtrace(cause.backtrace)
    end
  end

  # Error for when a file already exists or belongs to another keg.
  class ConflictError < LinkError
    extend T::Sig

    sig { returns(String) }
    def suggestion
      conflict = Keg.for(dst)
    rescue NotAKegError, Errno::ENOENT
      "already exists. You may want to remove it:\n  rm '#{dst}'\n"
    else
      <<~EOS
        is a symlink belonging to #{conflict.name}. You can unlink it:
          brew unlink #{conflict.name}
      EOS
    end

    sig { returns(String) }
    def to_s
      s = []
      s << "Could not symlink #{src}"
      s << "Target #{dst}" << suggestion
      s << <<~EOS
        To force the link and overwrite all conflicting files:
          brew link --overwrite #{keg.name}

        To list all files that would be deleted:
          brew link --overwrite --dry-run #{keg.name}
      EOS
      s.join("\n")
    end
  end

  # Error for when a directory is not writable.
  class DirectoryNotWritableError < LinkError
    extend T::Sig

    sig { returns(String) }
    def to_s
      <<~EOS
        Could not symlink #{src}
        #{dst.dirname} is not writable.
      EOS
    end
  end

  # Locale-specific directories have the form `language[_territory][.codeset][@modifier]`
  LOCALEDIR_RX = %r{(locale|man)/([a-z]{2}|C|POSIX)(_[A-Z]{2})?(\.[a-zA-Z\-0-9]+(@.+)?)?}.freeze
  INFOFILE_RX = %r{info/([^.].*?\.info|dir)$}.freeze
  KEG_LINK_DIRECTORIES = %w[
    bin etc include lib sbin share var
  ].freeze
  MUST_EXIST_SUBDIRECTORIES = (
    KEG_LINK_DIRECTORIES - %w[var] + %w[
      opt
      var/homebrew/linked
    ]
  ).map { |dir| HOMEBREW_PREFIX/dir }.sort.uniq.freeze

  # Keep relatively in sync with
  # {https://github.com/Homebrew/install/blob/HEAD/install.sh}
  MUST_EXIST_DIRECTORIES = (MUST_EXIST_SUBDIRECTORIES + [
    HOMEBREW_CELLAR,
  ].sort.uniq).freeze
  MUST_BE_WRITABLE_DIRECTORIES = (
    %w[
      etc/bash_completion.d lib/pkgconfig
      share/aclocal share/doc share/info share/locale share/man
      share/man/man1 share/man/man2 share/man/man3 share/man/man4
      share/man/man5 share/man/man6 share/man/man7 share/man/man8
      share/zsh share/zsh/site-functions
      var/log
    ].map { |dir| HOMEBREW_PREFIX/dir } + MUST_EXIST_SUBDIRECTORIES + [
      HOMEBREW_CACHE,
      HOMEBREW_CELLAR,
      HOMEBREW_LOCKS,
      HOMEBREW_LOGS,
      HOMEBREW_REPOSITORY,
      Language::Python.homebrew_site_packages,
    ]
  ).sort.uniq.freeze

  # These paths relative to the keg's share directory should always be real
  # directories in the prefix, never symlinks.
  SHARE_PATHS = %w[
    aclocal doc info java locale man
    man/man1 man/man2 man/man3 man/man4
    man/man5 man/man6 man/man7 man/man8
    man/cat1 man/cat2 man/cat3 man/cat4
    man/cat5 man/cat6 man/cat7 man/cat8
    applications gnome gnome/help icons
    mime-info pixmaps sounds postgresql
  ].freeze

  ELISP_EXTENSIONS = %w[.el .elc].freeze
  PYC_EXTENSIONS = %w[.pyc .pyo].freeze
  LIBTOOL_EXTENSIONS = %w[.la .lai].freeze

  # Given an array of kegs, this method will try to find some other kegs
  # that depend on them. If it does, it returns:
  #
  # - some kegs in the passed array that have installed dependents
  # - some installed dependents of those kegs.
  #
  # If it doesn't, it returns nil.
  #
  # Note that nil will be returned if the only installed dependents
  # in the passed kegs are other kegs in the array.
  #
  # For efficiency, we don't bother trying to get complete data.
  def self.find_some_installed_dependents(kegs)
    keg_names = kegs.select(&:optlinked?).map(&:name)
    keg_formulae = []
    kegs_by_source = kegs.group_by do |keg|
      # First, attempt to resolve the keg to a formula
      # to get up-to-date name and tap information.
      f = keg.to_formula
      keg_formulae << f
      [f.name, f.tap]
    rescue
      # If the formula for the keg can't be found,
      # fall back to the information in the tab.
      [keg.name, keg.tab.tap]
    end

    all_required_kegs = Set.new
    all_dependents = []

    # Don't include dependencies of kegs that were in the given array.
    formulae_to_check = Formula.installed - keg_formulae

    formulae_to_check.each do |dependent|
      required = dependent.missing_dependencies(hide: keg_names)
      required_kegs = required.map do |f|
        f_kegs = kegs_by_source[[f.name, f.tap]]
        next unless f_kegs

        f_kegs.max_by(&:version)
      end.compact

      next if required_kegs.empty?

      all_required_kegs += required_kegs
      all_dependents << dependent.to_s
    end

    return if all_required_kegs.empty?
    return if all_dependents.empty?

    [all_required_kegs.to_a, all_dependents.sort]
  end

  # @param path if this is a file in a keg, returns the containing {Keg} object.
  def self.for(path)
    original_path = path
    raise Errno::ENOENT, original_path.to_s unless original_path.exist?

    if (path = original_path.realpath)
      until path.root?
        return Keg.new(path) if path.parent.parent == HOMEBREW_CELLAR.realpath

        path = path.parent.realpath # realpath() prevents root? failing
      end
    end
    raise NotAKegError, "#{original_path} is not inside a keg"
  end

  def self.all
    Formula.racks.flat_map(&:subdirs).map { |d| new(d) }
  end

  attr_reader :path, :name, :linked_keg_record, :opt_record

  protected :path

  extend Forwardable

  def_delegators :path,
                 :to_s, :hash, :abv, :disk_usage, :file_count, :directory?, :exist?, :/,
                 :join, :rename, :find

  def initialize(path)
    path = path.resolved_path if path.to_s.start_with?("#{HOMEBREW_PREFIX}/opt/")
    raise "#{path} is not a valid keg" if path.parent.parent.realpath != HOMEBREW_CELLAR.realpath
    raise "#{path} is not a directory" unless path.directory?

    @path = path
    @name = path.parent.basename.to_s
    @linked_keg_record = HOMEBREW_LINKED_KEGS/name
    @opt_record = HOMEBREW_PREFIX/"opt/#{name}"
    @require_relocation = false
  end

  def rack
    path.parent
  end

  alias to_path to_s

  sig { returns(String) }
  def inspect
    "#<#{self.class.name}:#{path}>"
  end

  def ==(other)
    instance_of?(other.class) && path == other.path
  end
  alias eql? ==

  sig { returns(T::Boolean) }
  def empty_installation?
    Pathname.glob("#{path}/*") do |file|
      return false if file.directory? && !file.children.reject(&:ds_store?).empty?

      basename = file.basename.to_s
      next if Metafiles.copy?(basename)
      next if %w[.DS_Store INSTALL_RECEIPT.json].include?(basename)

      return false
    end

    true
  end

  def require_relocation?
    @require_relocation
  end

  def linked?
    linked_keg_record.symlink? &&
      linked_keg_record.directory? &&
      path == linked_keg_record.resolved_path
  end

  def remove_linked_keg_record
    linked_keg_record.unlink
    linked_keg_record.parent.rmdir_if_possible
  end

  def optlinked?
    opt_record.symlink? && path == opt_record.resolved_path
  end

  def remove_old_aliases
    opt = opt_record.parent
    linkedkegs = linked_keg_record.parent

    tap = begin
      to_formula.tap
    rescue
      # If the formula can't be found, just ignore aliases for now.
      nil
    end

    if tap
      bad_tap_opt = opt/tap.user
      FileUtils.rm_rf bad_tap_opt if !bad_tap_opt.symlink? && bad_tap_opt.directory?
    end

    aliases.each do |a|
      # versioned aliases are handled below
      next if a.match?(/.+@./)

      alias_opt_symlink = opt/a
      if alias_opt_symlink.symlink? && alias_opt_symlink.exist?
        alias_opt_symlink.delete if alias_opt_symlink.realpath == opt_record.realpath
      elsif alias_opt_symlink.symlink? || alias_opt_symlink.exist?
        alias_opt_symlink.delete
      end

      alias_linkedkegs_symlink = linkedkegs/a
      alias_linkedkegs_symlink.delete if alias_linkedkegs_symlink.symlink? || alias_linkedkegs_symlink.exist?
    end

    Pathname.glob("#{opt_record}@*").each do |a|
      a = a.basename.to_s
      next if aliases.include?(a)

      alias_opt_symlink = opt/a
      if alias_opt_symlink.symlink? && alias_opt_symlink.exist? && rack == alias_opt_symlink.realpath.parent
        alias_opt_symlink.delete
      end

      alias_linkedkegs_symlink = linkedkegs/a
      alias_linkedkegs_symlink.delete if alias_linkedkegs_symlink.symlink? || alias_linkedkegs_symlink.exist?
    end
  end

  def remove_opt_record
    opt_record.unlink
    opt_record.parent.rmdir_if_possible
  end

  def uninstall
    CacheStoreDatabase.use(:linkage) do |db|
      break unless db.created?

      LinkageCacheStore.new(path, db).delete!
    end

    path.rmtree
    path.parent.rmdir_if_possible
    remove_opt_record if optlinked?
    remove_old_aliases
    remove_oldname_opt_record
  rescue Errno::EACCES, Errno::ENOTEMPTY
    odie <<~EOS
      Could not remove #{name} keg! Do so manually:
        sudo rm -rf #{path}
    EOS
  end

  # TODO: refactor to use keyword arguments.
  def unlink(**options)
    ObserverPathnameExtension.reset_counts!

    dirs = []

    keg_directories = KEG_LINK_DIRECTORIES.map { |d| path/d }
                                          .select(&:exist?)
    keg_directories.each do |dir|
      dir.find do |src|
        dst = HOMEBREW_PREFIX + src.relative_path_from(path)
        dst.extend(ObserverPathnameExtension)

        dirs << dst if dst.directory? && !dst.symlink?

        # check whether the file to be unlinked is from the current keg first
        next unless dst.symlink?
        next if src != dst.resolved_path

        if options[:dry_run]
          puts dst
          Find.prune if src.directory?
          next
        end

        dst.uninstall_info if dst.to_s.match?(INFOFILE_RX)
        dst.unlink
        remove_old_aliases
        Find.prune if src.directory?
      end
    end

    unless options[:dry_run]
      remove_linked_keg_record if linked?
      dirs.reverse_each(&:rmdir_if_possible)
    end

    ObserverPathnameExtension.n
  end

  def lock(&block)
    FormulaLock.new(name).with_lock do
      if oldname_opt_record
        FormulaLock.new(oldname_opt_record.basename.to_s).with_lock(&block)
      else
        yield
      end
    end
  end

  def completion_installed?(shell)
    dir = case shell
    when :bash then path/"etc/bash_completion.d"
    when :zsh
      dir = path/"share/zsh/site-functions"
      dir if dir.directory? && dir.children.any? { |f| f.basename.to_s.start_with?("_") }
    when :fish then path/"share/fish/vendor_completions.d"
    end
    dir&.directory? && !dir.children.empty?
  end

  def functions_installed?(shell)
    case shell
    when :fish
      dir = path/"share/fish/vendor_functions.d"
      dir.directory? && !dir.children.empty?
    when :zsh
      # Check for non completion functions (i.e. files not started with an underscore),
      # since those can be checked separately
      dir = path/"share/zsh/site-functions"
      dir.directory? && dir.children.any? { |f| !f.basename.to_s.start_with?("_") }
    end
  end

  sig { returns(T::Boolean) }
  def plist_installed?
    !Dir["#{path}/*.plist"].empty?
  end

  def python_site_packages_installed?
    (path/"lib/python2.7/site-packages").directory?
  end

  sig { returns(T::Boolean) }
  def python_pth_files_installed?
    !Dir["#{path}/lib/python2.7/site-packages/*.pth"].empty?
  end

  sig { returns(T::Array[Pathname]) }
  def apps
    app_prefix = optlinked? ? opt_record : path
    Pathname.glob("#{app_prefix}/{,libexec/}*.app")
  end

  def elisp_installed?
    return false unless (path/"share/emacs/site-lisp"/name).exist?

    (path/"share/emacs/site-lisp"/name).children.any? { |f| ELISP_EXTENSIONS.include? f.extname }
  end

  def version
    require "pkg_version"
    PkgVersion.parse(path.basename.to_s)
  end

  def to_formula
    Formulary.from_keg(self)
  end

  def oldname_opt_record
    @oldname_opt_record ||= if (opt_dir = HOMEBREW_PREFIX/"opt").directory?
      opt_dir.subdirs.find do |dir|
        dir.symlink? && dir != opt_record && path.parent == dir.resolved_path.parent
      end
    end
  end

  # TODO: refactor to use keyword arguments.
  def link(**options)
    raise AlreadyLinkedError, self if linked_keg_record.directory?

    ObserverPathnameExtension.reset_counts!

    optlink(**options) unless options[:dry_run]

    # yeah indeed, you have to force anything you need in the main tree into
    # these dirs REMEMBER that *NOT* everything needs to be in the main tree
    link_dir("etc", **options) { :mkpath }
    link_dir("bin", **options) { :skip_dir }
    link_dir("sbin", **options) { :skip_dir }
    link_dir("include", **options) { :link }

    link_dir("share", **options) do |relative_path|
      case relative_path.to_s
      when INFOFILE_RX then :info
      when "locale/locale.alias",
           %r{^icons/.*/icon-theme\.cache$}
        :skip_file
      when LOCALEDIR_RX,
           %r{^icons/}, # all icons subfolders should also mkpath
           /^zsh/,
           /^fish/,
           %r{^lua/}, #  Lua, Lua51, Lua53 all need the same handling.
           %r{^guile/},
           *SHARE_PATHS
        :mkpath
      else
        :link
      end
    end

    link_dir("lib", **options) do |relative_path|
      case relative_path.to_s
      when "charset.alias"
        :skip_file
      when "pkgconfig", # pkg-config database gets explicitly created
           "cmake",     # cmake database gets explicitly created
           "dtrace",    # lib/language folders also get explicitly created
           /^gdk-pixbuf/,
           "ghc",
           /^gio/,
           "lua",
           /^mecab/,
           /^node/,
           /^ocaml/,
           /^perl5/,
           "php",
           /^python[23]\.\d/,
           /^R/,
           /^ruby/
        :mkpath
      else
        # Everything else is symlinked to the cellar
        :link
      end
    end

    link_dir("Frameworks", **options) do |relative_path|
      # Frameworks contain symlinks pointing into a subdir, so we have to use
      # the :link strategy. However, for Foo.framework and
      # Foo.framework/Versions we have to use :mkpath so that multiple formulae
      # can link their versions into it and `brew [un]link` works.
      if relative_path.to_s.match?(%r{[^/]*\.framework(/Versions)?$})
        :mkpath
      else
        :link
      end
    end

    make_relative_symlink(linked_keg_record, path, **options) unless options[:dry_run]
  rescue LinkError
    unlink(verbose: options[:verbose])
    raise
  else
    ObserverPathnameExtension.n
  end

  def remove_oldname_opt_record
    return unless oldname_opt_record
    return if oldname_opt_record.resolved_path != path

    @oldname_opt_record.unlink
    @oldname_opt_record.parent.rmdir_if_possible
    @oldname_opt_record = nil
  end

  def tab
    Tab.for_keg(self)
  end

  def runtime_dependencies
    Keg.cache[:runtime_dependencies] ||= {}
    Keg.cache[:runtime_dependencies][path] ||= tab.runtime_dependencies
  end

  def aliases
    tab.aliases || []
  end

  def optlink(**options)
    opt_record.delete if opt_record.symlink? || opt_record.exist?
    make_relative_symlink(opt_record, path, **options)
    aliases.each do |a|
      alias_opt_record = opt_record.parent/a
      alias_opt_record.delete if alias_opt_record.symlink? || alias_opt_record.exist?
      make_relative_symlink(alias_opt_record, path, **options)
    end

    return unless oldname_opt_record

    oldname_opt_record.delete
    make_relative_symlink(oldname_opt_record, path, **options)
  end

  def delete_pyc_files!
    find { |pn| pn.delete if PYC_EXTENSIONS.include?(pn.extname) }
    find { |pn| FileUtils.rm_rf pn if pn.basename.to_s == "__pycache__" }
  end

  private

  def resolve_any_conflicts(dst, **options)
    return unless dst.symlink?

    src = dst.resolved_path

    # src itself may be a symlink, so check lstat to ensure we are dealing with
    # a directory, and not a symlink pointing at a directory (which needs to be
    # treated as a file). In other words, we only want to resolve one symlink.

    begin
      stat = src.lstat
    rescue Errno::ENOENT
      # dst is a broken symlink, so remove it.
      dst.unlink unless options[:dry_run]
      return
    end

    return unless stat.directory?

    begin
      keg = Keg.for(src)
    rescue NotAKegError
      puts "Won't resolve conflicts for symlink #{dst} as it doesn't resolve into the Cellar" if options[:verbose]
      return
    end

    dst.unlink unless options[:dry_run]
    keg.link_dir(src, **options) { :mkpath }
    true
  end

  def make_relative_symlink(dst, src, **options)
    if dst.symlink? && src == dst.resolved_path
      puts "Skipping; link already exists: #{dst}" if options[:verbose]
      return
    end

    # cf. git-clean -n: list files to delete, don't really link or delete
    if options[:dry_run] && options[:overwrite]
      if dst.symlink?
        puts "#{dst} -> #{dst.resolved_path}"
      elsif dst.exist?
        puts dst
      end
      return
    end

    # list all link targets
    if options[:dry_run]
      puts dst
      return
    end

    dst.delete if options[:overwrite] && (dst.exist? || dst.symlink?)
    dst.make_relative_symlink(src)
  rescue Errno::EEXIST => e
    raise ConflictError.new(self, src.relative_path_from(path), dst, e) if dst.exist?

    if dst.symlink?
      dst.unlink
      retry
    end
  rescue Errno::EACCES => e
    raise DirectoryNotWritableError.new(self, src.relative_path_from(path), dst, e)
  rescue SystemCallError => e
    raise LinkError.new(self, src.relative_path_from(path), dst, e)
  end

  protected

  # symlinks the contents of path+relative_dir recursively into #{HOMEBREW_PREFIX}/relative_dir
  def link_dir(relative_dir, **options)
    root = path/relative_dir
    return unless root.exist?

    root.find do |src|
      next if src == root

      dst = HOMEBREW_PREFIX + src.relative_path_from(path)
      dst.extend ObserverPathnameExtension

      if src.symlink? || src.file?
        Find.prune if File.basename(src) == ".DS_Store"
        Find.prune if src.resolved_path == dst
        # Don't link pyc or pyo files because Python overwrites these
        # cached object files and next time brew wants to link, the
        # file is in the way.
        Find.prune if PYC_EXTENSIONS.include?(src.extname) && src.to_s.include?("/site-packages/")

        case yield src.relative_path_from(root)
        when :skip_file, nil
          Find.prune
        when :info
          next if File.basename(src) == "dir" # skip historical local 'dir' files

          make_relative_symlink dst, src, **options
          dst.install_info
        else
          make_relative_symlink dst, src, **options
        end
      elsif src.directory?
        # if the dst dir already exists, then great! walk the rest of the tree tho
        next if dst.directory? && !dst.symlink?

        # no need to put .app bundles in the path, the user can just use
        # spotlight, or the open command and actual mac apps use an equivalent
        Find.prune if src.extname == ".app"

        case yield src.relative_path_from(root)
        when :skip_dir
          Find.prune
        when :mkpath
          dst.mkpath unless resolve_any_conflicts(dst, **options)
        else
          unless resolve_any_conflicts(dst, **options)
            make_relative_symlink dst, src, **options
            Find.prune
          end
        end
      end
    end
  end
end

require "extend/os/keg"
