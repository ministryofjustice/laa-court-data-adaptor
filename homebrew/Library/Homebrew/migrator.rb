# typed: false
# frozen_string_literal: true

require "lock_file"
require "keg"
require "tab"

# Helper class for migrating a formula from an old to a new name.
#
# @api private
class Migrator
  extend T::Sig

  include Context

  # Error for when a migration is necessary.
  class MigrationNeededError < RuntimeError
    def initialize(formula)
      super <<~EOS
        #{formula.oldname} was renamed to #{formula.name} and needs to be migrated.
        Please run `brew migrate #{formula.oldname}`
      EOS
    end
  end

  # Error for when a formula does not replace another formula.
  class MigratorNoOldnameError < RuntimeError
    def initialize(formula)
      super "#{formula.name} doesn't replace any formula."
    end
  end

  # Error for when the old name's path does not exist.
  class MigratorNoOldpathError < RuntimeError
    def initialize(formula)
      super "#{HOMEBREW_CELLAR/formula.oldname} doesn't exist."
    end
  end

  # Error for when a formula is migrated to a different tap without explicitly using its fully-qualified name.
  class MigratorDifferentTapsError < RuntimeError
    def initialize(formula, tap)
      msg = if tap.core_tap?
        "Please try to use #{formula.oldname} to refer to the formula.\n"
      elsif tap
        "Please try to use fully-qualified #{tap}/#{formula.oldname} to refer to the formula.\n"
      end

      super <<~EOS
        #{formula.name} from #{formula.tap} is given, but old name #{formula.oldname} was installed from #{tap || "path or url"}.
        #{msg}To force migration use `brew migrate --force #{formula.oldname}`.
      EOS
    end
  end

  # Instance of renamed formula.
  attr_reader :formula

  # Old name of the formula.
  attr_reader :oldname

  # Path to oldname's cellar.
  attr_reader :old_cellar

  # Path to oldname pin.
  attr_reader :old_pin_record

  # Path to oldname opt.
  attr_reader :old_opt_record

  # Oldname linked keg.
  attr_reader :old_linked_keg

  # Path to oldname's linked keg.
  attr_reader :old_linked_keg_record

  # Tabs from oldname kegs.
  attr_reader :old_tabs

  # Tap of the old name.
  attr_reader :old_tap

  # Resolved path to oldname pin.
  attr_reader :old_pin_link_record

  # New name of the formula.
  attr_reader :newname

  # Path to newname cellar according to new name.
  attr_reader :new_cellar

  # True if new cellar existed at initialization time.
  attr_reader :new_cellar_existed

  # Path to newname pin.
  attr_reader :new_pin_record

  # Path to newname keg that will be linked if old_linked_keg isn't nil.
  attr_reader :new_linked_keg_record

  def self.needs_migration?(formula)
    oldname = formula.oldname
    return false unless oldname

    oldname_rack = HOMEBREW_CELLAR/oldname
    return false if oldname_rack.symlink?
    return false unless oldname_rack.directory?

    true
  end

  def self.migrate_if_needed(formula, force:)
    return unless Migrator.needs_migration?(formula)

    begin
      migrator = Migrator.new(formula, force: force)
      migrator.migrate
    rescue => e
      onoe e
    end
  end

  def initialize(formula, force: false)
    @oldname = formula.oldname
    @newname = formula.name
    raise MigratorNoOldnameError, formula unless oldname

    @formula = formula
    @old_cellar = HOMEBREW_CELLAR/formula.oldname
    raise MigratorNoOldpathError, formula unless old_cellar.exist?

    @old_tabs = old_cellar.subdirs.map { |d| Tab.for_keg(Keg.new(d)) }
    @old_tap = old_tabs.first.tap

    raise MigratorDifferentTapsError.new(formula, old_tap) if !force && !from_same_tap_user?

    @new_cellar = HOMEBREW_CELLAR/formula.name
    @new_cellar_existed = @new_cellar.exist?

    if @old_linked_keg = linked_old_linked_keg
      @old_linked_keg_record = old_linked_keg.linked_keg_record if old_linked_keg.linked?
      @old_opt_record = old_linked_keg.opt_record if old_linked_keg.optlinked?
      @new_linked_keg_record = HOMEBREW_CELLAR/"#{newname}/#{File.basename(old_linked_keg)}"
    end

    @old_pin_record = HOMEBREW_PINNED_KEGS/oldname
    @new_pin_record = HOMEBREW_PINNED_KEGS/newname
    @pinned = old_pin_record.symlink?
    @old_pin_link_record = old_pin_record.readlink if @pinned
  end

  # Fix `INSTALL_RECEIPT`s for tap-migrated formula.
  def fix_tabs
    old_tabs.each do |tab|
      tab.tap = formula.tap
      tab.write
    end
  end

  sig { returns(T::Boolean) }
  def from_same_tap_user?
    formula_tap_user = formula.tap.user if formula.tap
    old_tap_user = nil

    new_tap = if old_tap
      old_tap_user, = old_tap.user
      if migrate_tap = old_tap.tap_migrations[formula.oldname]
        new_tap_user, new_tap_repo = migrate_tap.split("/")
        "#{new_tap_user}/#{new_tap_repo}"
      end
    end

    if formula_tap_user == old_tap_user
      true
    # Homebrew didn't use to update tabs while performing tap-migrations,
    # so there can be `INSTALL_RECEIPT`s containing wrong information about tap,
    # so we check if there is an entry about oldname migrated to tap and if
    # newname's tap is the same as tap to which oldname migrated, then we
    # can perform migrations and the taps for oldname and newname are the same.
    elsif formula.tap && old_tap && formula.tap == new_tap
      fix_tabs
      true
    else
      false
    end
  end

  def linked_old_linked_keg
    keg_dirs = []
    keg_dirs += new_cellar.subdirs if new_cellar.exist?
    keg_dirs += old_cellar.subdirs
    kegs = keg_dirs.map { |d| Keg.new(d) }
    kegs.find(&:linked?) || kegs.find(&:optlinked?)
  end

  def pinned?
    @pinned
  end

  def migrate
    oh1 "Processing #{Formatter.identifier(oldname)} formula rename to #{Formatter.identifier(newname)}"
    lock
    unlink_oldname
    unlink_newname if new_cellar.exist?
    repin
    move_to_new_directory
    link_oldname_cellar
    link_oldname_opt
    link_newname unless old_linked_keg.nil?
    update_tabs
    return unless formula.outdated?

    opoo <<~EOS
      #{Formatter.identifier(newname)} is outdated!
      To avoid broken installations, as soon as possible please run:
        brew upgrade
      Or, if you're OK with a less reliable fix:
        brew upgrade #{newname}
    EOS
  rescue Interrupt
    ignore_interrupts { backup_oldname }
  rescue Exception => e # rubocop:disable Lint/RescueException
    onoe "Error occurred while migrating."
    puts e
    puts e.backtrace if debug?
    puts "Backing up..."
    ignore_interrupts { backup_oldname }
  ensure
    unlock
  end

  # Move everything from `Cellar/oldname` to `Cellar/newname`.
  def move_to_new_directory
    return unless old_cellar.exist?

    if new_cellar.exist?
      conflicted = T.let(false, T::Boolean)
      old_cellar.each_child do |c|
        next unless (new_cellar/c.basename).exist?

        begin
          FileUtils.rm_rf c
        rescue Errno::EACCES
          conflicted = true
          onoe "#{new_cellar/c.basename} already exists."
        end
      end

      odie "Remove #{new_cellar} manually and run `brew migrate #{oldname}`." if conflicted
    end

    oh1 "Moving #{Formatter.identifier(oldname)} versions to #{new_cellar}"
    if new_cellar.exist?
      FileUtils.mv(old_cellar.children, new_cellar)
    else
      FileUtils.mv(old_cellar, new_cellar)
    end
  end

  def repin
    return unless pinned?

    # old_pin_record is a relative symlink and when we try to to read it
    # from <dir> we actually try to find file
    # <dir>/../<...>/../Cellar/name/version.
    # To repin formula we need to update the link thus that it points to
    # the right directory.
    # NOTE: old_pin_record.realpath.sub(oldname, newname) is unacceptable
    # here, because it resolves every symlink for old_pin_record and then
    # substitutes oldname with newname. It breaks things like
    # Pathname#make_relative_symlink, where Pathname#relative_path_from
    # is used to find relative path from source to destination parent and
    # it assumes no symlinks.
    src_oldname = (old_pin_record.dirname/old_pin_link_record).expand_path
    new_pin_record.make_relative_symlink(src_oldname.sub(oldname, newname))
    old_pin_record.delete
  end

  def unlink_oldname
    oh1 "Unlinking #{Formatter.identifier(oldname)}"
    old_cellar.subdirs.each do |d|
      keg = Keg.new(d)
      keg.unlink(verbose: verbose?)
    end
  end

  def unlink_newname
    oh1 "Temporarily unlinking #{Formatter.identifier(newname)}"
    new_cellar.subdirs.each do |d|
      keg = Keg.new(d)
      keg.unlink(verbose: verbose?)
    end
  end

  def link_newname
    oh1 "Relinking #{Formatter.identifier(newname)}"
    new_keg = Keg.new(new_linked_keg_record)

    # If old_keg wasn't linked then we just optlink a keg.
    # If old keg wasn't optlinked and linked, we don't call this method at all.
    # If formula is keg-only we also optlink it.
    if formula.keg_only? || !old_linked_keg_record
      begin
        new_keg.optlink(verbose: verbose?)
      rescue Keg::LinkError => e
        onoe "Failed to create #{formula.opt_prefix}"
        raise
      end
      return
    end

    new_keg.remove_linked_keg_record if new_keg.linked?

    begin
      new_keg.link(overwrite: true, verbose: verbose?)
    rescue Keg::ConflictError => e
      onoe "Error while executing `brew link` step on #{newname}"
      puts e
      puts
      puts "Possible conflicting files are:"
      new_keg.link(dry_run: true, overwrite: true, verbose: verbose?)
      raise
    rescue Keg::LinkError => e
      onoe "Error while linking"
      puts e
      puts
      puts "You can try again using:"
      puts "  brew link #{formula.name}"
    rescue Exception => e # rubocop:disable Lint/RescueException
      onoe "An unexpected error occurred during linking"
      puts e
      puts e.backtrace if debug?
      ignore_interrupts { new_keg.unlink(verbose: verbose?) }
      raise
    end
  end

  # Link keg to opt if it was linked before migrating.
  def link_oldname_opt
    return unless old_opt_record

    old_opt_record.delete if old_opt_record.symlink?
    old_opt_record.make_relative_symlink(new_linked_keg_record)
  end

  # After migration every `INSTALL_RECEIPT.json` has the wrong path to the formula
  # so we must update `INSTALL_RECEIPT`s.
  def update_tabs
    new_tabs = new_cellar.subdirs.map { |d| Tab.for_keg(Keg.new(d)) }
    new_tabs.each do |tab|
      tab.source["path"] = formula.path.to_s if tab.source["path"]
      tab.write
    end
  end

  # Remove `opt/oldname` link if it belongs to newname.
  def unlink_oldname_opt
    return unless old_opt_record

    if old_opt_record.symlink? && old_opt_record.exist? \
        && new_linked_keg_record.exist? \
        && new_linked_keg_record.realpath == old_opt_record.realpath
      old_opt_record.unlink
      old_opt_record.parent.rmdir_if_possible
    end
  end

  # Remove `Cellar/oldname` if it exists.
  def link_oldname_cellar
    old_cellar.delete if old_cellar.symlink? || old_cellar.exist?
    old_cellar.make_relative_symlink(formula.rack)
  end

  # Remove `Cellar/oldname` link if it belongs to newname.
  def unlink_oldname_cellar
    if (old_cellar.symlink? && !old_cellar.exist?) || (old_cellar.symlink? \
          && formula.rack.exist? && formula.rack.realpath == old_cellar.realpath)
      old_cellar.unlink
    end
  end

  # Backup everything if errors occur while migrating.
  def backup_oldname
    unlink_oldname_opt
    unlink_oldname_cellar
    backup_oldname_cellar
    backup_old_tabs

    if pinned? && !old_pin_record.symlink?
      src_oldname = (old_pin_record.dirname/old_pin_link_record).expand_path
      old_pin_record.make_relative_symlink(src_oldname)
      new_pin_record.delete
    end

    if new_cellar.exist?
      new_cellar.subdirs.each do |d|
        newname_keg = Keg.new(d)
        newname_keg.unlink(verbose: verbose?)
        newname_keg.uninstall if new_cellar_existed
      end
    end

    return if old_linked_keg.nil?

    # The keg used to be linked and when we backup everything we restore
    # Cellar/oldname, the target also gets restored, so we are able to
    # create a keg using its old path
    if old_linked_keg_record
      begin
        old_linked_keg.link(verbose: verbose?)
      rescue Keg::LinkError
        old_linked_keg.unlink(verbose: verbose?)
        raise
      rescue Keg::AlreadyLinkedError
        old_linked_keg.unlink(verbose: verbose?)
        retry
      end
    else
      old_linked_keg.optlink(verbose: verbose?)
    end
  end

  def backup_oldname_cellar
    FileUtils.mv(new_cellar, old_cellar) unless old_cellar.exist?
  end

  def backup_old_tabs
    old_tabs.each(&:write)
  end

  def lock
    @newname_lock = FormulaLock.new newname
    @oldname_lock = FormulaLock.new oldname
    @newname_lock.lock
    @oldname_lock.lock
  end

  def unlock
    @newname_lock.unlock
    @oldname_lock.unlock
  end
end
