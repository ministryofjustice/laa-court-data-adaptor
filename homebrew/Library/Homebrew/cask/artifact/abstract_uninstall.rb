# typed: false
# frozen_string_literal: true

require "timeout"

require "utils/user"
require "cask/artifact/abstract_artifact"
require "cask/pkg"
require "extend/hash_validator"
using HashValidator

module Cask
  module Artifact
    # Abstract superclass for uninstall artifacts.
    #
    # @api private
    class AbstractUninstall < AbstractArtifact
      extend T::Sig

      ORDERED_DIRECTIVES = [
        :early_script,
        :launchctl,
        :quit,
        :signal,
        :login_item,
        :kext,
        :script,
        :pkgutil,
        :delete,
        :trash,
        :rmdir,
      ].freeze

      def self.from_args(cask, **directives)
        new(cask, directives)
      end

      attr_reader :directives

      def initialize(cask, directives)
        directives.assert_valid_keys!(*ORDERED_DIRECTIVES)

        super(cask)
        directives[:signal] = Array(directives[:signal]).flatten.each_slice(2).to_a
        @directives = directives

        return unless directives.key?(:kext)

        cask.caveats do
          kext
        end
      end

      def to_h
        directives.to_h
      end

      sig { returns(String) }
      def summarize
        to_h.flat_map { |key, val| Array(val).map { |v| "#{key.inspect} => #{v.inspect}" } }.join(", ")
      end

      private

      def dispatch_uninstall_directives(**options)
        ORDERED_DIRECTIVES.each do |directive_sym|
          dispatch_uninstall_directive(directive_sym, **options)
        end
      end

      def dispatch_uninstall_directive(directive_sym, **options)
        return unless directives.key?(directive_sym)

        args = directives[directive_sym]

        send("uninstall_#{directive_sym}", *(args.is_a?(Hash) ? [args] : args), **options)
      end

      def stanza
        self.class.dsl_key
      end

      # Preserve prior functionality of script which runs first. Should rarely be needed.
      # :early_script should not delete files, better defer that to :script.
      # If cask writers never need :early_script it may be removed in the future.
      def uninstall_early_script(directives, **options)
        uninstall_script(directives, directive_name: :early_script, **options)
      end

      # :launchctl must come before :quit/:signal for cases where app would instantly re-launch
      def uninstall_launchctl(*services, command: nil, **_)
        booleans = [false, true]
        services.each do |service|
          ohai "Removing launchctl service #{service}"
          booleans.each do |with_sudo|
            plist_status = command.run(
              "/bin/launchctl",
              args: ["list", service],
              sudo: with_sudo, print_stderr: false
            ).stdout
            if plist_status.start_with?("{")
              command.run!("/bin/launchctl", args: ["remove", service], sudo: with_sudo)
              sleep 1
            end
            paths = [
              +"/Library/LaunchAgents/#{service}.plist",
              +"/Library/LaunchDaemons/#{service}.plist",
            ]
            paths.each { |elt| elt.prepend(ENV["HOME"]).freeze } unless with_sudo
            paths = paths.map { |elt| Pathname(elt) }.select(&:exist?)
            paths.each do |path|
              command.run!("/bin/rm", args: ["-f", "--", path], sudo: with_sudo)
            end
            # undocumented and untested: pass a path to uninstall :launchctl
            next unless Pathname(service).exist?

            command.run!("/bin/launchctl", args: ["unload", "-w", "--", service], sudo: with_sudo)
            command.run!("/bin/rm", args: ["-f", "--", service], sudo: with_sudo)
            sleep 1
          end
        end
      end

      def running_processes(bundle_id)
        system_command!("/bin/launchctl", args: ["list"])
          .stdout.lines
          .map { |line| line.chomp.split("\t") }
          .map { |pid, state, id| [pid.to_i, state.to_i, id] }
          .select do |(pid, _, id)|
            pid.nonzero? && /^#{Regexp.escape(bundle_id)}($|\.\d+)/.match?(id)
          end
      end

      sig { returns(String) }
      def automation_access_instructions
        "Enable Automation Access for “Terminal > System Events” in " \
        "“System Preferences > Security > Privacy > Automation” if you haven't already."
      end

      # :quit/:signal must come before :kext so the kext will not be in use by a running process
      def uninstall_quit(*bundle_ids, command: nil, **_)
        bundle_ids.each do |bundle_id|
          next unless running?(bundle_id)

          unless User.current.gui?
            opoo "Not logged into a GUI; skipping quitting application ID '#{bundle_id}'."
            next
          end

          ohai "Quitting application '#{bundle_id}'..."

          begin
            Timeout.timeout(10) do
              Kernel.loop do
                next unless quit(bundle_id).success?

                next if running?(bundle_id)

                puts "Application '#{bundle_id}' quit successfully."
                break
              end
            end
          rescue Timeout::Error
            opoo "Application '#{bundle_id}' did not quit. #{automation_access_instructions}"
          end
        end
      end

      def running?(bundle_id)
        script = <<~JAVASCRIPT
          'use strict';

          ObjC.import('stdlib')

          function run(argv) {
            try {
              var app = Application(argv[0])
              if (app.running()) {
                $.exit(0)
              }
            } catch (err) { }

            $.exit(1)
          }
        JAVASCRIPT

        system_command("osascript", args:         ["-l", "JavaScript", "-e", script, bundle_id],
                                    print_stderr: true).status.success?
      end

      def quit(bundle_id)
        script = <<~JAVASCRIPT
          'use strict';

          ObjC.import('stdlib')

          function run(argv) {
            var app = Application(argv[0])

            try {
              app.quit()
            } catch (err) {
              if (app.running()) {
                $.exit(1)
              }
            }

            $.exit(0)
          }
        JAVASCRIPT

        system_command "osascript", args:         ["-l", "JavaScript", "-e", script, bundle_id],
                                    print_stderr: false
      end
      private :quit

      # :signal should come after :quit so it can be used as a backup when :quit fails
      def uninstall_signal(*signals, command: nil, **_)
        signals.each do |pair|
          raise CaskInvalidError.new(cask, "Each #{stanza} :signal must consist of 2 elements.") unless pair.size == 2

          signal, bundle_id = pair
          ohai "Signalling '#{signal}' to application ID '#{bundle_id}'"
          pids = running_processes(bundle_id).map(&:first)
          next unless pids.any?

          # Note that unlike :quit, signals are sent from the current user (not
          # upgraded to the superuser). This is a todo item for the future, but
          # there should be some additional thought/safety checks about that, as a
          # misapplied "kill" by root could bring down the system. The fact that we
          # learned the pid from AppleScript is already some degree of protection,
          # though indirect.
          odebug "Unix ids are #{pids.inspect} for processes with bundle identifier #{bundle_id}"
          Process.kill(signal, *pids)
          sleep 3
        end
      end

      def uninstall_login_item(*login_items, command: nil, upgrade: false, **_)
        return if upgrade

        apps = cask.artifacts.select { |a| a.class.dsl_key == :app }
        derived_login_items = apps.map { |a| { path: a.target } }

        [*derived_login_items, *login_items].each do |item|
          type, id = if item.respond_to?(:key) && item.key?(:path)
            ["path", item[:path]]
          else
            ["name", item]
          end

          ohai "Removing login item #{id}"

          result = system_command(
            "osascript",
            args: [
              "-e",
              %Q(tell application "System Events" to delete every login item whose #{type} is #{id.to_s.inspect}),
            ],
          )

          opoo "Removal of login item #{id} failed. #{automation_access_instructions}" unless result.success?

          sleep 1
        end
      end

      # :kext should be unloaded before attempting to delete the relevant file
      def uninstall_kext(*kexts, command: nil, **_)
        kexts.each do |kext|
          ohai "Unloading kernel extension #{kext}"
          is_loaded = system_command!("/usr/sbin/kextstat", args: ["-l", "-b", kext], sudo: true).stdout
          if is_loaded.length > 1
            system_command!("/sbin/kextunload", args: ["-b", kext], sudo: true)
            sleep 1
          end
          system_command!("/usr/sbin/kextfind", args: ["-b", kext], sudo: true).stdout.chomp.lines.each do |kext_path|
            ohai "Removing kernel extension #{kext_path}"
            system_command!("/bin/rm", args: ["-rf", kext_path], sudo: true)
          end
        end
      end

      # :script must come before :pkgutil, :delete, or :trash so that the script file is not already deleted
      def uninstall_script(directives, directive_name: :script, force: false, command: nil, **_)
        # TODO: Create a common `Script` class to run this and Artifact::Installer.
        executable, script_arguments = self.class.read_script_arguments(directives,
                                                                        "uninstall",
                                                                        { must_succeed: true, sudo: false },
                                                                        { print_stdout: true },
                                                                        directive_name)

        ohai "Running uninstall script #{executable}"
        raise CaskInvalidError.new(cask, "#{stanza} :#{directive_name} without :executable.") if executable.nil?

        executable_path = staged_path_join_executable(executable)

        if (executable_path.absolute? && !executable_path.exist?) ||
           (!executable_path.absolute? && (which executable_path).nil?)
          message = "uninstall script #{executable} does not exist"
          raise CaskError, "#{message}." unless force

          opoo "#{message}, skipping."
          return
        end

        command.run(executable_path, script_arguments)
        sleep 1
      end

      def uninstall_pkgutil(*pkgs, command: nil, **_)
        ohai "Uninstalling packages:"
        pkgs.each do |regex|
          ::Cask::Pkg.all_matching(regex, command).each do |pkg|
            puts pkg.package_id
            pkg.uninstall
          end
        end
      end

      def each_resolved_path(action, paths)
        return enum_for(:each_resolved_path, action, paths) unless block_given?

        paths.each do |path|
          resolved_path = Pathname.new(path)

          resolved_path = resolved_path.expand_path if path.to_s.start_with?("~")

          if resolved_path.relative? || resolved_path.split.any? { |part| part.to_s == ".." }
            opoo "Skipping #{Formatter.identifier(action)} for relative path '#{path}'."
            next
          end

          if MacOS.undeletable?(resolved_path)
            opoo "Skipping #{Formatter.identifier(action)} for undeletable path '#{path}'."
            next
          end

          begin
            yield path, Pathname.glob(resolved_path)
          rescue Errno::EPERM
            raise if File.readable?(File.expand_path("~/Library/Application Support/com.apple.TCC"))

            odie "Unable to remove some files. Please enable Full Disk Access for your terminal under " \
                 "System Preferences → Security & Privacy → Privacy → Full Disk Access."
          end
        end
      end

      def uninstall_delete(*paths, command: nil, **_)
        return if paths.empty?

        ohai "Removing files:"
        each_resolved_path(:delete, paths) do |path, resolved_paths|
          puts path
          command.run!(
            "/usr/bin/xargs",
            args:  ["-0", "--", "/bin/rm", "-r", "-f", "--"],
            input: resolved_paths.join("\0"),
            sudo:  true,
          )
        end
      end

      def uninstall_trash(*paths, **options)
        return if paths.empty?

        resolved_paths = each_resolved_path(:trash, paths).to_a

        ohai "Trashing files:"
        puts resolved_paths.map(&:first)
        trash_paths(*resolved_paths.flat_map(&:last), **options)
      end

      def trash_paths(*paths, command: nil, **_)
        return if paths.empty?

        stdout, stderr, = system_command HOMEBREW_LIBRARY_PATH/"cask/utils/trash.swift",
                                         args:         paths,
                                         print_stderr: false

        trashed = stdout.split(":").sort
        untrashable = stderr.split(":").sort

        return trashed, untrashable if untrashable.empty?

        untrashable.delete_if do |path|
          Utils.gain_permissions(path, ["-R"], SystemCommand) do
            system_command! HOMEBREW_LIBRARY_PATH/"cask/utils/trash.swift",
                            args:         [path],
                            print_stderr: false
          end

          true
        rescue
          false
        end

        opoo "The following files could not trashed, please do so manually:"
        $stderr.puts untrashable

        [trashed, untrashable]
      end

      def all_dirs?(*directories)
        directories.all?(&:directory?)
      end

      def recursive_rmdir(*directories, command: nil, **_)
        success = true
        each_resolved_path(:rmdir, directories) do |_path, resolved_paths|
          resolved_paths.select(&method(:all_dirs?)).each do |resolved_path|
            puts resolved_path.sub(Dir.home, "~")

            if (ds_store = resolved_path.join(".DS_Store")).exist?
              command.run!("/bin/rm", args: ["-f", "--", ds_store], sudo: true, print_stderr: false)
            end

            unless recursive_rmdir(*resolved_path.children, command: command)
              success = false
              next
            end

            status = command.run("/bin/rmdir", args: ["--", resolved_path], sudo: true, print_stderr: false).success?
            success &= status
          end
        end
        success
      end

      def uninstall_rmdir(*args)
        return if args.empty?

        ohai "Removing directories if empty:"
        recursive_rmdir(*args)
      end
    end
  end
end
