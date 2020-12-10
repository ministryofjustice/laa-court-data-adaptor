# typed: false
# frozen_string_literal: true

module Cask
  class DSL
    # Class corresponding to the `version` stanza.
    #
    # @api private
    class Version < ::String
      extend T::Sig

      DIVIDERS = {
        "." => :dots,
        "-" => :hyphens,
        "_" => :underscores,
      }.freeze

      DIVIDER_REGEX = /(#{DIVIDERS.keys.map { |v| Regexp.quote(v) }.join('|')})/.freeze

      MAJOR_MINOR_PATCH_REGEX = /^([^.,:]+)(?:.([^.,:]+)(?:.([^.,:]+))?)?/.freeze

      INVALID_CHARACTERS = /[^0-9a-zA-Z.,:\-_]/.freeze

      class << self
        private

        def define_divider_methods(divider)
          define_divider_deletion_method(divider)
          define_divider_conversion_methods(divider)
        end

        def define_divider_deletion_method(divider)
          method_name = deletion_method_name(divider)
          define_method(method_name) do
            version { delete(divider) }
          end
        end

        def deletion_method_name(divider)
          "no_#{DIVIDERS[divider]}"
        end

        def define_divider_conversion_methods(left_divider)
          (DIVIDERS.keys - [left_divider]).each do |right_divider|
            define_divider_conversion_method(left_divider, right_divider)
          end
        end

        def define_divider_conversion_method(left_divider, right_divider)
          method_name = conversion_method_name(left_divider, right_divider)
          define_method(method_name) do
            version { gsub(left_divider, right_divider) }
          end
        end

        def conversion_method_name(left_divider, right_divider)
          "#{DIVIDERS[left_divider]}_to_#{DIVIDERS[right_divider]}"
        end
      end

      DIVIDERS.each_key do |divider|
        define_divider_methods(divider)
      end

      attr_reader :raw_version

      sig { params(raw_version: T.nilable(T.any(String, Symbol))).void }
      def initialize(raw_version)
        @raw_version = raw_version
        super(raw_version.to_s)
      end

      def invalid_characters
        return [] if latest?

        raw_version.scan(INVALID_CHARACTERS)
      end

      sig { returns(T::Boolean) }
      def unstable?
        return false if latest?

        s = downcase.delete(".").gsub(/[^a-z\d]+/, "-")

        return true if s.match?(/(\d+|\b)(alpha|beta|preview|rc|dev|canary|snapshot)(\d+|\b)/i)
        return true if s.match?(/\A[a-z\d]+(-\d+)*-?(a|b|pre)(\d+|\b)/i)

        false
      end

      sig { returns(T::Boolean) }
      def latest?
        to_s == "latest"
      end

      def major
        version { slice(MAJOR_MINOR_PATCH_REGEX, 1) }
      end

      def minor
        version { slice(MAJOR_MINOR_PATCH_REGEX, 2) }
      end

      def patch
        version { slice(MAJOR_MINOR_PATCH_REGEX, 3) }
      end

      def major_minor
        version { [major, minor].reject(&:empty?).join(".") }
      end

      def major_minor_patch
        version { [major, minor, patch].reject(&:empty?).join(".") }
      end

      def minor_patch
        version { [minor, patch].reject(&:empty?).join(".") }
      end

      def before_comma
        version { split(",", 2).first }
      end

      def after_comma
        version { split(",", 2).second }
      end

      def before_colon
        version { split(":", 2).first }
      end

      def after_colon
        version { split(":", 2).second }
      end

      def no_dividers
        version { gsub(DIVIDER_REGEX, "") }
      end

      private

      sig { returns(T.self_type) }
      def version
        return self if empty? || latest?

        self.class.new(yield)
      end
    end
  end
end
