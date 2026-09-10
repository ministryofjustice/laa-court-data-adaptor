# frozen_string_literal: true

require "rspec/expectations"

# have_contract_error
# e.g.
# expect(contract.call(my_integer: '1')).to have_contract_error('must be an integer')
#
RSpec::Matchers.define :have_contract_error do |message|
  match do |fullfilment|
    fullfilment.errors.map(&:text).any? { |msg| msg.match?(Regexp.escape(message)) }
  end

  description do
    "have contract error"
  end

  failure_message do |fullfilment|
    errors = fullfilment.errors.to_h
    "expected contract fullfilment errors to include message: \"#{message}\"\n" \
      "but received: #{errors.empty? ? 'none' : errors}"
  end

  failure_message_when_negated do |fullfilment|
    "expected contract fullfilment not to include error message \"#{message}\"\n" \
      "but it was included in #{fullfilment.errors.to_h}"
  end
end
