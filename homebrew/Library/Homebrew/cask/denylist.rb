# typed: strict
# frozen_string_literal: true

module Cask
  # List of casks which are not allowed in official taps.
  #
  # @api private
  module Denylist
    extend T::Sig

    sig { params(name: String).returns(T.nilable(String)) }
    def self.reason(name)
      case name
      when /^adobe-(after|illustrator|indesign|photoshop|premiere)/
        "Adobe casks were removed because they are too difficult to maintain."
      when /^audacity$/
        "Audacity was removed because it is too difficult to download programmatically."
      when /^pharo$/
        "Pharo developers maintain their own tap."
      end
    end
  end
end
