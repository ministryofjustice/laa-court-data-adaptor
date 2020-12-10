# typed: strict
# frozen_string_literal: true

require "cask/artifact/moved"

module Cask
  module Artifact
    # Artifact corresponding to the `app` stanza.
    #
    # @api private
    class App < Moved
    end
  end
end
