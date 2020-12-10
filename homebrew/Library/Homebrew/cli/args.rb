# typed: true
# frozen_string_literal: true

require "ostruct"

module Homebrew
  module CLI
    class Args < OpenStruct
      extend T::Sig

      attr_reader :options_only, :flags_only

      # undefine tap to allow --tap argument
      undef tap

      sig { void }
      def initialize
        require "cli/named_args"

        super()

        @processed_options = []
        @options_only = []
        @flags_only = []

        # Can set these because they will be overwritten by freeze_named_args!
        # (whereas other values below will only be overwritten if passed).
        self[:named] = NamedArgs.new(parent: self)
        self[:remaining] = []
      end

      def freeze_remaining_args!(remaining_args)
        self[:remaining] = remaining_args.freeze
      end

      def freeze_named_args!(named_args)
        self[:named] = NamedArgs.new(
          *named_args.freeze,
          override_spec: spec(nil),
          force_bottle:  force_bottle?,
          flags:         flags_only,
          parent:        self,
        )
      end

      def freeze_processed_options!(processed_options)
        # Reset cache values reliant on processed_options
        @cli_args = nil

        @processed_options += processed_options
        @processed_options.freeze

        @options_only = cli_args.select { |a| a.start_with?("-") }.freeze
        @flags_only = cli_args.select { |a| a.start_with?("--") }.freeze
      end

      sig { returns(NamedArgs) }
      def named
        require "formula"
        self[:named]
      end

      def no_named?
        named.blank?
      end

      def formulae
        odisabled "args.formulae", "args.named.to_formulae"
      end

      def formulae_and_casks
        odisabled "args.formulae_and_casks", "args.named.to_formulae_and_casks"
      end

      def resolved_formulae
        odisabled "args.resolved_formulae", "args.named.to_resolved_formulae"
      end

      def resolved_formulae_casks
        odisabled "args.resolved_formulae_casks", "args.named.to_resolved_formulae_to_casks"
      end

      def formulae_paths
        odisabled "args.formulae_paths", "args.named.to_formulae_paths"
      end

      def casks
        odisabled "args.casks", "args.named.homebrew_tap_cask_names"
      end

      def loaded_casks
        odisabled "args.loaded_casks", "args.named.to_cask"
      end

      def kegs
        odisabled "args.kegs", "args.named.to_kegs"
      end

      def kegs_casks
        odisabled "args.kegs", "args.named.to_kegs_to_casks"
      end

      def build_stable?
        !HEAD?
      end

      def build_from_source_formulae
        if build_from_source? || build_bottle?
          named.to_formulae_and_casks.select { |f| f.is_a?(Formula) }.map(&:full_name)
        else
          []
        end
      end

      def include_test_formulae
        if include_test?
          named.to_formulae.map(&:full_name)
        else
          []
        end
      end

      def value(name)
        arg_prefix = "--#{name}="
        flag_with_value = flags_only.find { |arg| arg.start_with?(arg_prefix) }
        return unless flag_with_value

        flag_with_value.delete_prefix(arg_prefix)
      end

      sig { returns(Context::ContextStruct) }
      def context
        Context::ContextStruct.new(debug: debug?, quiet: quiet?, verbose: verbose?)
      end

      private

      def option_to_name(option)
        option.sub(/\A--?/, "")
              .tr("-", "_")
      end

      def cli_args
        return @cli_args if @cli_args

        @cli_args = []
        @processed_options.each do |short, long|
          option = long || short
          switch = "#{option_to_name(option)}?".to_sym
          flag = option_to_name(option).to_sym
          if @table[switch] == true || @table[flag] == true
            @cli_args << option
          elsif @table[flag].instance_of? String
            @cli_args << "#{option}=#{@table[flag]}"
          elsif @table[flag].instance_of? Array
            @cli_args << "#{option}=#{@table[flag].join(",")}"
          end
        end
        @cli_args.freeze
      end

      def spec(default = :stable)
        if HEAD?
          :head
        else
          default
        end
      end
    end
  end
end
