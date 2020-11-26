# frozen_string_literal: true

class CrownCourtOutcomeCreator < ApplicationService
  GUILTY_VERDICTS = %w[GUILTY GUILTY_BUT_OF_ALTERNATIVE_OFFENCE_BY_JURY_CONVICTED GUILTY_BUT_OF_LESSER_OFFENCE_BY_JURY_CONVICTED GUILTY_BY_JURY_CONVICTED GUILTY_CONVICTED].freeze

  SUCCESSFUL_APPEALS = %w[Granted Allowed].freeze

  def initialize(defendant:, appeal_data:)
    @defendant = defendant
    @appeal_data = appeal_data
  end

  def call
    appeal_data.present? ? appeal_hash : trial_hash
  end

private

  def trial_hash
    {
      ccooOutcome: trial_outcome,
      caseEndDate: trial_end_date,
      appealType: nil,
    }
  end

  def appeal_hash
    {
      ccooOutcome: appeal_outcome,
      caseEndDate: appeal_end_date,
      appealType: appeal_data[:appeal_type],
    }
  end

  def trial_outcome
    return "CONVICTED" if defendant[:offences]&.all? do |offence|
      GUILTY_VERDICTS.include? offence.dig(:verdict, :verdictType, :categoryType)
    end
    return "PART CONVICTED" if defendant[:offences]&.any? do |offence|
      GUILTY_VERDICTS.include? offence.dig(:verdict, :verdictType, :categoryType)
    end

    "AQUITTED" # This incorrect spelling is used in the MAAT database, and so must be used here to ensure compatibility
  end

  def appeal_outcome
    return "SUCCESSFUL" if SUCCESSFUL_APPEALS.include? appeal_data&.dig(:appeal_outcome, :applicationOutcome)

    "UNSUCCESSFUL"
  end

  def trial_end_date
    defendant.dig(:offences, 0, :verdict, :verdictDate)
  end

  def appeal_end_date
    appeal_data.dig(:appeal_outcome, :applicationOutcomeDate)
  end

  attr_reader :defendant, :appeal_data
end
