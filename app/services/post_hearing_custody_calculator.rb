# frozen_string_literal: true

class PostHearingCustodyCalculator < ApplicationService
  NOT_APPLICABLE_CUSTODY_CODE = "A"

  def initialize(offences:)
    @offences = offences
  end

  def call
    offences.flat_map { |offence|
      offence[:judicialResults]&.filter_map do |result|
        result[:postHearingCustodyStatus] if result[:postHearingCustodyStatus] != NOT_APPLICABLE_CUSTODY_CODE
      end
    }.first || NOT_APPLICABLE_CUSTODY_CODE
  end

private

  attr_reader :offences
end
