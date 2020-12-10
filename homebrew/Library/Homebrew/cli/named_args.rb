# typed: false
# frozen_string_literal: true

require "delegate"

require "cli/args"

module Homebrew
  module CLI
    # Helper class for loading formulae/casks from named arguments.
    #
    # @api private
    class NamedArgs < Array
      extend T::Sig

      def initialize(*args, parent: Args.new, override_spec: nil, force_bottle: false, flags: [])
        require "cask/cask"
        require "cask/cask_loader"
        require "formulary"
        require "keg"
        require "missing_formula"

        @args = args
        @override_spec = override_spec
        @force_bottle = force_bottle
        @flags = flags
        @parent = parent

        super(@args)
      end

      def to_casks
        @to_casks ||= to_formulae_and_casks(only: :cask).freeze
      end

      def to_formulae
        @to_formulae ||= to_formulae_and_casks(only: :formula).freeze
      end

      # Convert named arguments to {Formula} or {Cask} objects.
      # If both a formula and cask with the same name exist, returns
      # the formula and prints a warning unless `only` is specified.
      sig do
        params(only: T.nilable(Symbol), ignore_unavailable: T.nilable(T::Boolean), method: T.nilable(Symbol))
          .returns(T::Array[T.any(Formula, Keg, Cask::Cask)])
      end
      def to_formulae_and_casks(only: nil, ignore_unavailable: nil, method: nil)
        @to_formulae_and_casks ||= {}
        @to_formulae_and_casks[only] ||= downcased_unique_named.flat_map do |name|
          load_formula_or_cask(name, only: only, method: method)
        rescue NoSuchKegError, FormulaUnavailableError, Cask::CaskUnavailableError
          ignore_unavailable ? [] : raise
        end.uniq.freeze
      end

      def to_formulae_to_casks(only: nil, method: nil)
        @to_formulae_to_casks ||= {}
        @to_formulae_to_casks[[method, only]] = to_formulae_and_casks(only: only, method: method)
                                                .partition { |o| o.is_a?(Formula) }
                                                .map(&:freeze).freeze
      end

      def to_formulae_and_casks_and_unavailable(only: nil, method: nil)
        @to_formulae_casks_unknowns ||= {}
        @to_formulae_casks_unknowns[method] = downcased_unique_named.map do |name|
          load_formula_or_cask(name, only: only, method: method)
        rescue FormulaOrCaskUnavailableError => e
          e
        end.uniq.freeze
      end

      def load_formula_or_cask(name, only: nil, method: nil)
        if only != :cask
          begin
            formula = case method
            when nil, :factory
              Formulary.factory(name, *spec, force_bottle: @force_bottle, flags: @flags)
            when :resolve
              resolve_formula(name)
            when :keg
              resolve_keg(name)
            when :kegs
              rack = Formulary.to_rack(name)
              rack.directory? ? rack.subdirs.map { |d| Keg.new(d) } : []
            else
              raise
            end

            warn_if_cask_conflicts(name, "formula") unless only == :formula
            return formula
          rescue NoSuchKegError, FormulaUnavailableError => e
            raise e if only == :formula
          end
        end

        if only != :formula
          begin
            return Cask::CaskLoader.load(name, config: Cask::Config.from_args(@parent))
          rescue Cask::CaskUnavailableError => e
            retry if Tap.install_default_cask_tap_if_necessary

            raise e if only == :cask
          end
        end

        raise FormulaOrCaskUnavailableError, name
      end
      private :load_formula_or_cask

      def resolve_formula(name)
        Formulary.resolve(name, spec: spec, force_bottle: @force_bottle, flags: @flags)
      end
      private :resolve_formula

      sig { returns(T::Array[Formula]) }
      def to_resolved_formulae
        @to_resolved_formulae ||= to_formulae_and_casks(only: :formula, method: :resolve)
                                  .freeze
      end

      def to_resolved_formulae_to_casks(only: nil)
        to_formulae_to_casks(only: only, method: :resolve)
      end

      def to_formulae_paths
        to_paths(only: :formula)
      end

      # Keep existing paths and try to convert others to tap, formula or cask paths.
      # If a cask and formula with the same name exist, includes both their paths
      # unless `only` is specified.
      def to_paths(only: nil)
        @to_paths ||= {}
        @to_paths[only] ||= downcased_unique_named.flat_map do |name|
          if File.exist?(name)
            Pathname(name)
          elsif name.count("/") == 1 && !name.start_with?("./", "/")
            Tap.fetch(name).path
          else
            next Formulary.path(name) if only == :formula
            next Cask::CaskLoader.path(name) if only == :cask

            formula_path = Formulary.path(name)
            cask_path = Cask::CaskLoader.path(name)

            paths = []

            paths << formula_path if formula_path.exist?
            paths << cask_path if cask_path.exist?

            paths.empty? ? Pathname(name) : paths
          end
        end.uniq.freeze
      end

      sig { returns(T::Array[Keg]) }
      def to_kegs
        @to_kegs ||= begin
          to_formulae_and_casks(only: :formula, method: :keg).freeze
        rescue NoSuchKegError => e
          if (reason = MissingFormula.suggest_command(e.name, "uninstall"))
            $stderr.puts reason
          end
          raise e
        end
      end

      sig do
        params(only: T.nilable(Symbol), ignore_unavailable: T.nilable(T::Boolean), all_kegs: T.nilable(T::Boolean))
          .returns([T::Array[Keg], T::Array[Cask::Cask]])
      end
      def to_kegs_to_casks(only: nil, ignore_unavailable: nil, all_kegs: nil)
        method = all_kegs ? :kegs : :keg
        @to_kegs_to_casks ||= {}
        @to_kegs_to_casks[method] ||=
          to_formulae_and_casks(only: only, ignore_unavailable: ignore_unavailable, method: method)
          .partition { |o| o.is_a?(Keg) }
          .map(&:freeze).freeze
      end

      sig { returns(T::Array[String]) }
      def homebrew_tap_cask_names
        downcased_unique_named.grep(HOMEBREW_CASK_TAP_CASK_REGEX)
      end

      private

      sig { returns(T::Array[String]) }
      def downcased_unique_named
        # Only lowercase names, not paths, bottle filenames or URLs
        map do |arg|
          if arg.include?("/") || arg.end_with?(".tar.gz") || File.exist?(arg)
            arg
          else
            arg.downcase
          end
        end.uniq
      end

      def spec
        @override_spec
      end
      private :spec

      def resolve_keg(name)
        raise UsageError if name.blank?

        require "keg"

        rack = Formulary.to_rack(name.downcase)

        dirs = rack.directory? ? rack.subdirs : []
        raise NoSuchKegError, rack.basename if dirs.empty?

        linked_keg_ref = HOMEBREW_LINKED_KEGS/rack.basename
        opt_prefix = HOMEBREW_PREFIX/"opt/#{rack.basename}"

        begin
          if opt_prefix.symlink? && opt_prefix.directory?
            Keg.new(opt_prefix.resolved_path)
          elsif linked_keg_ref.symlink? && linked_keg_ref.directory?
            Keg.new(linked_keg_ref.resolved_path)
          elsif dirs.length == 1
            Keg.new(dirs.first)
          else
            f = if name.include?("/") || File.exist?(name)
              Formulary.factory(name)
            else
              Formulary.from_rack(rack)
            end

            unless (prefix = f.latest_installed_prefix).directory?
              raise MultipleVersionsInstalledError, <<~EOS
                #{rack.basename} has multiple installed versions
                Run `brew uninstall --force #{rack.basename}` to remove all versions.
              EOS
            end

            Keg.new(prefix)
          end
        rescue FormulaUnavailableError
          raise MultipleVersionsInstalledError, <<~EOS
            Multiple kegs installed to #{rack}
            However we don't know which one you refer to.
            Please delete (with rm -rf!) all but one and then try again.
          EOS
        end
      end

      def warn_if_cask_conflicts(ref, loaded_type)
        cask = Cask::CaskLoader.load ref
        message = "Treating #{ref} as a #{loaded_type}."
        message += " For the cask, use #{cask.tap.name}/#{cask.token}" if cask.tap.present?
        opoo message.freeze
      rescue Cask::CaskUnavailableError
        # No ref conflict with a cask, do nothing
      end
    end
  end
end
