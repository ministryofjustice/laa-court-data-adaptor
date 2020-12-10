# typed: false
# frozen_string_literal: true

require "formula"
require "utils/bottles"
require "tab"
require "keg"
require "formula_versions"
require "cli/parser"
require "utils/inreplace"
require "erb"

BOTTLE_ERB = <<-EOS
  bottle do
    <% if root_url != "#{HOMEBREW_BOTTLE_DEFAULT_DOMAIN}/bottles" %>
    root_url "<%= root_url %>"
    <% end %>
    <% if ![HOMEBREW_DEFAULT_PREFIX,
            HOMEBREW_MACOS_ARM_DEFAULT_PREFIX,
            HOMEBREW_LINUX_DEFAULT_PREFIX].include?(prefix) %>
    prefix "<%= prefix %>"
    <% end %>
    <% if cellar.is_a? Symbol %>
    cellar :<%= cellar %>
    <% elsif ![Homebrew::DEFAULT_MACOS_CELLAR,
               Homebrew::DEFAULT_MACOS_ARM_CELLAR,
               Homebrew::DEFAULT_LINUX_CELLAR].include?(cellar) %>
    cellar "<%= cellar %>"
    <% end %>
    <% if rebuild.positive? %>
    rebuild <%= rebuild %>
    <% end %>
    <% checksums.each do |checksum_type, checksum_values| %>
    <% checksum_values.each do |checksum_value| %>
    <% checksum, macos = checksum_value.shift %>
    <%= checksum_type %> "<%= checksum %>" => :<%= macos %>
    <% end %>
    <% end %>
  end
EOS

MAXIMUM_STRING_MATCHES = 100

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def bottle_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `bottle` [<options>] <formula>

        Generate a bottle (binary package) from a formula that was installed with
        `--build-bottle`.
        If the formula specifies a rebuild version, it will be incremented in the
        generated DSL. Passing `--keep-old` will attempt to keep it at its original
        value, while `--no-rebuild` will remove it.
      EOS
      switch "--skip-relocation",
             description: "Do not check if the bottle can be marked as relocatable."
      switch "--force-core-tap",
             description: "Build a bottle even if <formula> is not in `homebrew/core` or any installed taps."
      switch "--no-rebuild",
             description: "If the formula specifies a rebuild version, remove it from the generated DSL."
      switch "--keep-old",
             description: "If the formula specifies a rebuild version, attempt to preserve its value in the "\
                          "generated DSL."
      switch "--json",
             description: "Write bottle information to a JSON file, which can be used as the value for "\
                          "`--merge`."
      switch "--merge",
             description: "Generate an updated bottle block for a formula and optionally merge it into the "\
                          "formula file. Instead of a formula name, requires the path to a JSON file generated with "\
                          "`brew bottle --json` <formula>."
      switch "--write",
             depends_on:  "--merge",
             description: "Write changes to the formula file. A new commit will be generated unless "\
                          "`--no-commit` is passed."
      switch "--no-commit",
             depends_on:  "--write",
             description: "When passed with `--write`, a new commit will not generated after writing changes "\
                          "to the formula file."
      flag   "--root-url=",
             description: "Use the specified <URL> as the root of the bottle's URL instead of Homebrew's default."

      conflicts "--no-rebuild", "--keep-old"
      min_named 1
    end
  end

  def bottle
    args = bottle_args.parse

    return merge(args: args) if args.merge?

    ensure_relocation_formulae_installed! unless args.skip_relocation?
    args.named.to_resolved_formulae.each do |f|
      bottle_formula f, args: args
    end
  end

  def ensure_relocation_formulae_installed!
    Keg.relocation_formulae.each do |f|
      next if Formula[f].latest_version_installed?

      ohai "Installing #{f}..."
      safe_system HOMEBREW_BREW_FILE, "install", f
    end
  end

  def keg_contain?(string, keg, ignores, formula_and_runtime_deps_names = nil, args:)
    @put_string_exists_header, @put_filenames = nil

    print_filename = lambda do |str, filename|
      unless @put_string_exists_header
        opoo "String '#{str}' still exists in these files:"
        @put_string_exists_header = true
      end

      @put_filenames ||= []

      return if @put_filenames.include?(filename)

      puts Formatter.error(filename.to_s)
      @put_filenames << filename
    end

    result = false

    keg.each_unique_file_matching(string) do |file|
      next if Metafiles::EXTENSIONS.include?(file.extname) # Skip document files.

      linked_libraries = Keg.file_linked_libraries(file, string)
      result ||= !linked_libraries.empty?

      if args.verbose?
        print_filename.call(string, file) unless linked_libraries.empty?
        linked_libraries.each do |lib|
          puts " #{Tty.bold}-->#{Tty.reset} links to #{lib}"
        end
      end

      text_matches = []

      # Use strings to search through the file for each string
      Utils.popen_read("strings", "-t", "x", "-", file.to_s) do |io|
        until io.eof?
          str = io.readline.chomp
          next if ignores.any? { |i| i =~ str }
          next unless str.include? string

          offset, match = str.split(" ", 2)
          next if linked_libraries.include? match # Don't bother reporting a string if it was found by otool

          # Do not report matches to files that do not exist.
          next unless File.exist? match

          # Do not report matches to build dependencies.
          if formula_and_runtime_deps_names.present?
            begin
              keg_name = Keg.for(Pathname.new(match)).name
              next unless formula_and_runtime_deps_names.include? keg_name
            rescue NotAKegError
              nil
            end
          end

          result = true
          text_matches << [match, offset]
        end
      end

      next unless args.verbose? && !text_matches.empty?

      print_filename.call(string, file)
      text_matches.first(MAXIMUM_STRING_MATCHES).each do |match, offset|
        puts " #{Tty.bold}-->#{Tty.reset} match '#{match}' at offset #{Tty.bold}0x#{offset}#{Tty.reset}"
      end

      if text_matches.size > MAXIMUM_STRING_MATCHES
        puts "Only the first #{MAXIMUM_STRING_MATCHES} matches were output."
      end
    end

    keg_contain_absolute_symlink_starting_with?(string, keg, args: args) || result
  end

  def keg_contain_absolute_symlink_starting_with?(string, keg, args:)
    absolute_symlinks_start_with_string = []
    keg.find do |pn|
      next unless pn.symlink? && (link = pn.readlink).absolute?

      absolute_symlinks_start_with_string << pn if link.to_s.start_with?(string)
    end

    if args.verbose? && absolute_symlinks_start_with_string.present?
      opoo "Absolute symlink starting with #{string}:"
      absolute_symlinks_start_with_string.each do |pn|
        puts "  #{pn} -> #{pn.resolved_path}"
      end
    end

    !absolute_symlinks_start_with_string.empty?
  end

  def bottle_output(bottle)
    erb = ERB.new BOTTLE_ERB
    erb.result(bottle.instance_eval { binding }).gsub(/^\s*$\n/, "")
  end

  def sudo_purge
    return unless ENV["HOMEBREW_BOTTLE_SUDO_PURGE"]

    system "/usr/bin/sudo", "--non-interactive", "/usr/sbin/purge"
  end

  def bottle_formula(f, args:)
    return ofail "Formula not installed or up-to-date: #{f.full_name}" unless f.latest_version_installed?

    unless tap = f.tap
      return ofail "Formula not from core or any installed taps: #{f.full_name}" unless args.force_core_tap?

      tap = CoreTap.instance
    end

    if f.bottle_disabled?
      ofail "Formula has disabled bottle: #{f.full_name}"
      puts f.bottle_disable_reason
      return
    end

    return ofail "Formula was not installed with --build-bottle: #{f.full_name}" unless Utils::Bottles.built_as? f

    return ofail "Formula has no stable version: #{f.full_name}" unless f.stable

    if args.no_rebuild? || !f.tap
      rebuild = 0
    elsif args.keep_old?
      rebuild = f.bottle_specification.rebuild
    else
      ohai "Determining #{f.full_name} bottle rebuild..."
      versions = FormulaVersions.new(f)
      rebuilds = versions.bottle_version_map("origin/master")[f.pkg_version]
      rebuilds.pop if rebuilds.last.to_i.positive?
      rebuild = rebuilds.empty? ? 0 : rebuilds.max.to_i + 1
    end

    filename = Bottle::Filename.create(f, Utils::Bottles.tag, rebuild)
    bottle_path = Pathname.pwd/filename

    tar_filename = filename.to_s.sub(/.gz$/, "")
    tar_path = Pathname.pwd/tar_filename

    prefix = HOMEBREW_PREFIX.to_s
    repository = HOMEBREW_REPOSITORY.to_s
    cellar = HOMEBREW_CELLAR.to_s

    ohai "Bottling #{filename}..."

    formula_and_runtime_deps_names = [f.name] + f.runtime_dependencies.map(&:name)
    keg = Keg.new(f.prefix)
    relocatable = T.let(false, T::Boolean)
    skip_relocation = T.let(false, T::Boolean)

    keg.lock do
      original_tab = nil
      changed_files = nil

      begin
        keg.delete_pyc_files!

        changed_files = keg.replace_locations_with_placeholders unless args.skip_relocation?

        Formula.clear_cache
        Keg.clear_cache
        Tab.clear_cache
        tab = Tab.for_keg(keg)
        original_tab = tab.dup
        tab.poured_from_bottle = false
        tab.HEAD = nil
        tab.time = nil
        tab.changed_files = changed_files
        tab.write

        keg.find do |file|
          if file.symlink?
            File.lutime(tab.source_modified_time, tab.source_modified_time, file)
          else
            file.utime(tab.source_modified_time, tab.source_modified_time)
          end
        end

        cd cellar do
          sudo_purge
          safe_system "tar", "cf", tar_path, "#{f.name}/#{f.pkg_version}"
          sudo_purge
          tar_path.utime(tab.source_modified_time, tab.source_modified_time)
          relocatable_tar_path = "#{f}-bottle.tar"
          mv tar_path, relocatable_tar_path
          # Use gzip, faster to compress than bzip2, faster to uncompress than bzip2
          # or an uncompressed tarball (and more bandwidth friendly).
          safe_system "gzip", "-f", relocatable_tar_path
          sudo_purge
          mv "#{relocatable_tar_path}.gz", bottle_path
        end

        ohai "Detecting if #{filename} is relocatable..." if bottle_path.size > 1 * 1024 * 1024

        prefix_check = if Homebrew.default_prefix?(prefix)
          File.join(prefix, "opt")
        else
          prefix
        end

        # Ignore matches to source code, which is not required at run time.
        # These matches may be caused by debugging symbols.
        ignores = [%r{/include/|\.(c|cc|cpp|h|hpp)$}]
        any_go_deps = f.deps.any? do |dep|
          dep.name =~ Version.formula_optionally_versioned_regex(:go)
        end
        if any_go_deps
          go_regex =
            Version.formula_optionally_versioned_regex(:go, full: false)
          ignores << %r{#{Regexp.escape(HOMEBREW_CELLAR)}/#{go_regex}/[\d.]+/libexec}
        end

        relocatable = true
        if args.skip_relocation?
          skip_relocation = true
        else
          relocatable = false if keg_contain?(prefix_check, keg, ignores, formula_and_runtime_deps_names, args: args)
          relocatable = false if keg_contain?(repository, keg, ignores, args: args)
          relocatable = false if keg_contain?(cellar, keg, ignores, formula_and_runtime_deps_names, args: args)
          if prefix != prefix_check
            relocatable = false if keg_contain_absolute_symlink_starting_with?(prefix, keg, args: args)
            relocatable = false if keg_contain?("#{prefix}/etc", keg, ignores, args: args)
            relocatable = false if keg_contain?("#{prefix}/var", keg, ignores, args: args)
            relocatable = false if keg_contain?("#{prefix}/share/vim", keg, ignores, args: args)
          end
          skip_relocation = relocatable && !keg.require_relocation?
        end
        puts if !relocatable && args.verbose?
      rescue Interrupt
        ignore_interrupts { bottle_path.unlink if bottle_path.exist? }
        raise
      ensure
        ignore_interrupts do
          original_tab&.write
          keg.replace_placeholders_with_locations changed_files unless args.skip_relocation?
        end
      end
    end

    root_url = args.root_url

    bottle = BottleSpecification.new
    bottle.tap = tap
    bottle.root_url(root_url) if root_url
    if relocatable
      if skip_relocation
        bottle.cellar :any_skip_relocation
      else
        bottle.cellar :any
      end
    else
      bottle.cellar cellar
      bottle.prefix prefix
    end
    bottle.rebuild rebuild
    sha256 = bottle_path.sha256
    bottle.sha256 sha256 => Utils::Bottles.tag

    old_spec = f.bottle_specification
    if args.keep_old? && !old_spec.checksums.empty?
      mismatches = [:root_url, :prefix, :cellar, :rebuild].reject do |key|
        old_spec.send(key) == bottle.send(key)
      end
      if (old_spec.cellar == :any && bottle.cellar == :any_skip_relocation) ||
         (old_spec.cellar == cellar &&
          [:any, :any_skip_relocation].include?(bottle.cellar))
        mismatches.delete(:cellar)
        bottle.cellar old_spec.cellar
      end
      unless mismatches.empty?
        bottle_path.unlink if bottle_path.exist?

        mismatches.map! do |key|
          old_value = old_spec.send(key).inspect
          value = bottle.send(key).inspect
          "#{key}: old: #{old_value}, new: #{value}"
        end

        odie <<~EOS
          --keep-old was passed but there are changes in:
          #{mismatches.join("\n")}
        EOS
      end
    end

    output = bottle_output bottle

    puts "./#{filename}"
    puts output

    return unless args.json?

    json = {
      f.full_name => {
        "formula" => {
          "pkg_version" => f.pkg_version.to_s,
          "path"        => f.path.to_s.delete_prefix("#{HOMEBREW_REPOSITORY}/"),
        },
        "bottle"  => {
          "root_url" => bottle.root_url,
          "prefix"   => bottle.prefix,
          "cellar"   => bottle.cellar.to_s,
          "rebuild"  => bottle.rebuild,
          "tags"     => {
            Utils::Bottles.tag.to_s => {
              "filename"       => filename.bintray,
              "local_filename" => filename.to_s,
              "sha256"         => sha256,
            },
          },
        },
        "bintray" => {
          "package"    => Utils::Bottles::Bintray.package(f.name),
          "repository" => Utils::Bottles::Bintray.repository(tap),
        },
      },
    }
    File.open(filename.json, "w") do |file|
      file.write JSON.generate json
    end
  end

  def merge(args:)
    bottles_hash = args.named.reduce({}) do |hash, json_file|
      hash.deep_merge(JSON.parse(IO.read(json_file))) do |key, first, second|
        if key == "cellar"
          # Prioritize HOMEBREW_CELLAR over :any over :any_skip_relocation
          cellars = [first, second]
          next HOMEBREW_CELLAR if cellars.include?(HOMEBREW_CELLAR)
          next first if first.start_with?("/")
          next second if second.start_with?("/")
          next "any" if cellars.include?("any")
          next "any_skip_relocation" if cellars.include?("any_skip_relocation")
        end

        second
      end
    end

    any_cellars = ["any", "any_skip_relocation"]
    bottles_hash.each do |formula_name, bottle_hash|
      ohai formula_name

      bottle = BottleSpecification.new
      bottle.root_url bottle_hash["bottle"]["root_url"]
      cellar = bottle_hash["bottle"]["cellar"]
      cellar = cellar.to_sym if any_cellars.include?(cellar)
      bottle.cellar cellar
      bottle.prefix bottle_hash["bottle"]["prefix"]
      bottle.rebuild bottle_hash["bottle"]["rebuild"]
      bottle_hash["bottle"]["tags"].each do |tag, tag_hash|
        bottle.sha256 tag_hash["sha256"] => tag.to_sym
      end

      output = bottle_output bottle

      if args.write?
        path = Pathname.new((HOMEBREW_REPOSITORY/bottle_hash["formula"]["path"]).to_s)
        update_or_add = T.let(nil, T.nilable(String))

        Utils::Inreplace.inreplace(path) do |s|
          if s.inreplace_string.include? "bottle do"
            update_or_add = "update"
            if args.keep_old?
              mismatches = []
              valid_keys = %w[root_url prefix cellar rebuild sha1 sha256]
              bottle_block_contents = s.inreplace_string[/  bottle do(.+?)end\n/m, 1]
              bottle_block_contents.lines.each do |line|
                line = line.strip
                next if line.empty?

                key, old_value_original, _, tag = line.split " ", 4
                next unless valid_keys.include?(key)

                old_value = old_value_original.to_s.delete "'\""
                old_value = old_value.to_s.delete ":" if key != "root_url"
                tag = tag.to_s.delete ":"

                unless tag.empty?
                  if bottle_hash["bottle"]["tags"][tag].present?
                    mismatches << "#{key} => #{tag}"
                  else
                    bottle.send(key, old_value => tag.to_sym)
                  end
                  next
                end

                value_original = bottle_hash["bottle"][key]
                value = value_original.to_s
                next if key == "cellar" && old_value == "any" && value == "any_skip_relocation"
                next unless old_value.empty? || value != old_value

                old_value = old_value_original.inspect
                value = value_original.inspect
                mismatches << "#{key}: old: #{old_value}, new: #{value}"
              end

              unless mismatches.empty?
                odie <<~EOS
                  --keep-old was passed but there are changes in:
                  #{mismatches.join("\n")}
                EOS
              end
              output = bottle_output bottle
            end
            puts output
            string = s.sub!(/  bottle do.+?end\n/m, output)
            odie "Bottle block update failed!" unless string
          else
            odie "--keep-old was passed but there was no existing bottle block!" if args.keep_old?
            puts output
            update_or_add = "add"
            pattern = /(
                (\ {2}\#[^\n]*\n)*                                                # comments
                \ {2}(                                                            # two spaces at the beginning
                  (url|head)\ ['"][\S\ ]+['"]                                     # url or head with a string
                  (
                    ,[\S\ ]*$                                                     # url may have options
                    (\n^\ {3}[\S\ ]+$)*                                           # options can be in multiple lines
                  )?|
                  (homepage|desc|sha256|version|mirror|license)\ ['"][\S\ ]+['"]| # specs with a string
                  license\ (
                    [^\[]+?\[[^\]]+?\]|                                           # license may contain a list
                    [^{]+?{[^}]+?}|                                               # license may contain a hash
                    :\S+                                                          # license as a symbol
                  )|
                  (revision|version_scheme)\ \d+|                                 # revision with a number
                  (stable|livecheck)\ do(\n+^\ {4}[\S\ ]+$)*\n+^\ {2}end          # components with blocks
                )\n+                                                              # multiple empty lines
               )+
             /mx
            string = s.sub!(pattern, "\\0#{output}\n")
            odie "Bottle block addition failed!" unless string
          end
        end

        unless args.no_commit?
          Utils::Git.set_name_email!
          Utils::Git.setup_gpg!

          short_name = formula_name.split("/", -1).last
          pkg_version = bottle_hash["formula"]["pkg_version"]

          path.parent.cd do
            safe_system "git", "commit", "--no-edit", "--verbose",
                        "--message=#{short_name}: #{update_or_add} #{pkg_version} bottle.",
                        "--", path
          end
        end
      else
        puts output
      end
    end
  end
end
