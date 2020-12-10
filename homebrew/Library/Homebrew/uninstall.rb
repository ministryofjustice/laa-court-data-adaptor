# typed: true
# frozen_string_literal: true

require "keg"

module Homebrew
  # Helper module for uninstalling kegs.
  #
  # @api private
  module Uninstall
    module_function

    def uninstall_kegs(kegs_by_rack, force: false, ignore_dependencies: false, named_args: [])
      handle_unsatisfied_dependents(kegs_by_rack,
                                    ignore_dependencies: ignore_dependencies,
                                    named_args:          named_args)
      return if Homebrew.failed?

      kegs_by_rack.each do |rack, kegs|
        if force
          name = rack.basename

          if rack.directory?
            puts "Uninstalling #{name}... (#{rack.abv})"
            kegs.each do |keg|
              keg.unlink
              keg.uninstall
            end
          end

          rm_pin rack
        else
          kegs.each do |keg|
            begin
              f = Formulary.from_rack(rack)
              if f.pinned?
                onoe "#{f.full_name} is pinned. You must unpin it to uninstall."
                next
              end
            rescue
              nil
            end

            keg.lock do
              puts "Uninstalling #{keg}... (#{keg.abv})"
              keg.unlink
              keg.uninstall
              rack = keg.rack
              rm_pin rack

              if rack.directory?
                versions = rack.subdirs.map(&:basename)
                puts "#{keg.name} #{versions.to_sentence} #{"is".pluralize(versions.count)} still installed."
                puts "Run `brew uninstall --force #{keg.name}` to remove all versions."
              end

              next unless f

              paths = f.pkgetc.find.map(&:to_s) if f.pkgetc.exist?
              if paths.present?
                puts
                opoo <<~EOS
                  The following #{f.name} configuration files have not been removed!
                  If desired, remove them manually with `rm -rf`:
                    #{paths.sort.uniq.join("\n  ")}
                EOS
              end

              unversioned_name = f.name.gsub(/@.+$/, "")
              maybe_paths = Dir.glob("#{f.etc}/*#{unversioned_name}*")
              maybe_paths -= paths if paths.present?
              if maybe_paths.present?
                puts
                opoo <<~EOS
                  The following may be #{f.name} configuration files and have not been removed!
                  If desired, remove them manually with `rm -rf`:
                    #{maybe_paths.sort.uniq.join("\n  ")}
                EOS
              end
            end
          end
        end
      end
    rescue MultipleVersionsInstalledError => e
      ofail e
    ensure
      # If we delete Cellar/newname, then Cellar/oldname symlink
      # can become broken and we have to remove it.
      if HOMEBREW_CELLAR.directory?
        HOMEBREW_CELLAR.children.each do |rack|
          rack.unlink if rack.symlink? && !rack.resolved_path_exists?
        end
      end
    end

    def handle_unsatisfied_dependents(kegs_by_rack, ignore_dependencies: false, named_args: [])
      return if ignore_dependencies

      all_kegs = kegs_by_rack.values.flatten(1)
      check_for_dependents(all_kegs, named_args: named_args)
    rescue MethodDeprecatedError
      # Silently ignore deprecations when uninstalling.
      nil
    end

    def check_for_dependents(kegs, named_args: [])
      return false unless result = Keg.find_some_installed_dependents(kegs)

      if Homebrew::EnvConfig.developer?
        DeveloperDependentsMessage.new(*result, named_args: named_args).output
      else
        NondeveloperDependentsMessage.new(*result, named_args: named_args).output
      end

      true
    end

    # @api private
    class DependentsMessage
      attr_reader :reqs, :deps, :named_args

      def initialize(requireds, dependents, named_args: [])
        @reqs = requireds
        @deps = dependents
        @named_args = named_args
      end

      protected

      def sample_command
        "brew uninstall --ignore-dependencies #{named_args.join(" ")}"
      end

      def are_required_by_deps
        "#{"is".pluralize(reqs.count)} required by #{deps.to_sentence}, " \
        "which #{"is".pluralize(deps.count)} currently installed"
      end
    end

    # @api private
    class DeveloperDependentsMessage < DependentsMessage
      def output
        opoo <<~EOS
          #{reqs.to_sentence} #{are_required_by_deps}.
          You can silence this warning with:
            #{sample_command}
        EOS
      end
    end

    # @api private
    class NondeveloperDependentsMessage < DependentsMessage
      def output
        ofail <<~EOS
          Refusing to uninstall #{reqs.to_sentence}
          because #{"it".pluralize(reqs.count)} #{are_required_by_deps}.
          You can override this and force removal with:
            #{sample_command}
        EOS
      end
    end

    def rm_pin(rack)
      Formulary.from_rack(rack).unpin
    rescue
      nil
    end
  end
end
