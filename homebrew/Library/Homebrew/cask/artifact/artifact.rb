# typed: false
# frozen_string_literal: true

require "cask/artifact/moved"

require "extend/hash_validator"
using HashValidator

module Cask
  module Artifact
    # Generic artifact corresponding to the `artifact` stanza.
    #
    # @api private
    class Artifact < Moved
      extend T::Sig

      sig { returns(String) }
      def self.english_name
        "Generic Artifact"
      end

      def self.from_args(cask, *args)
        source_string, target_hash = args

        raise CaskInvalidError.new(cask.token, "no source given for #{english_name}") if source_string.nil?

        unless target_hash.is_a?(Hash)
          raise CaskInvalidError.new(cask.token, "target required for #{english_name} '#{source_string}'")
        end

        target_hash.assert_valid_keys!(:target)

        new(cask, source_string, **target_hash)
      end

      def resolve_target(target)
        Pathname(target)
      end

      def initialize(cask, source, target: nil)
        super(cask, source, target: target)
      end
    end
  end
end
