# typed: strict
# frozen_string_literal: true

require "cask/artifact/moved"

module Cask
  module Artifact
    # Artifact corresponding to the `suite` stanza.
    #
    # @api private
    class Suite < Moved
      extend T::Sig

      sig { returns(String) }
      def self.english_name
        "App Suite"
      end

      sig { returns(Symbol) }
      def self.dirmethod
        :appdir
      end
    end
  end
end
