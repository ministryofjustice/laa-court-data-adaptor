# frozen_string_literal: true

require "rspec/expectations"

# have_contract_metadata
# e.g.
# expect(contract.call(my_integer: '1')).to have_contract_metadata({ code: :my_integer_not_an_integer })
#
RSpec::Matchers.define :have_contract_metadata do |meta|
  match do |fullfilment|
    fullfilment.errors.map(&:meta).any? { |msg| msg == meta }
  end

  description do
    "have contract metadata"
  end

  failure_message do |fullfilment|
    errors = fullfilment.errors.to_h
    "expected contract fullfilment errors to include metadata: \"#{meta}\"\n" \
      "but received: #{errors.empty? ? 'none' : errors}"
  end

  failure_message_when_negated do |fullfilment|
    "expected contract fullfilment not to include error metadata \"#{meta}\"\n" \
      "but it was included in #{fullfilment.errors.to_h}"
  end
end
