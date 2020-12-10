# typed: true
# frozen_string_literal: true

require "unpack_strategy"

module Cask
  class DSL
    # Class corresponding to the `container` stanza.
    #
    # @api private
    class Container
      VALID_KEYS = Set.new([
                             :type,
                             :nested,
                           ]).freeze

      attr_accessor(*VALID_KEYS, :pairs)

      def initialize(pairs = {})
        @pairs = pairs
        pairs.each do |key, value|
          raise "invalid container key: '#{key.inspect}'" unless VALID_KEYS.include?(key)

          send(:"#{key}=", value)
        end

        return if type.nil?
        return unless UnpackStrategy.from_type(type).nil?

        raise "invalid container type: #{type.inspect}"
      end

      def to_yaml
        @pairs.to_yaml
      end

      def to_s
        @pairs.inspect
      end
    end
  end
end
