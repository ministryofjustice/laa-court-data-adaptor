# frozen_string_literal: true

require "rspec/expectations"

# have_contract_error
# e.g.
# expect(contract.call(my_integer: '1')).to have_contract_error('must be an integer')
#
RSpec::Matchers.define :have_contract_error do |message|
  match do |fullfillment|
    fullfillment.errors.map(&:text).any? { |msg| msg.match?(message) }
  end

  description do
    "have contract error"
  end

  failure_message do |fullfillment|
    errors = fullfillment.errors.to_h
    "expected contract fullfillment errors to include message: \"#{message}\"\n" \
      "but received: #{errors.empty? ? 'none' : errors}"
  end

  failure_message_when_negated do |fullfillment|
    "expected contract fullfillment not to include error message \"#{message}\"\n" \
      "but it was included in #{fullfillment.errors.to_h}"
  end
end
