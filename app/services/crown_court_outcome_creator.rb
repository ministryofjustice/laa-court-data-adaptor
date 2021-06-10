# frozen_string_literal: true

class CrownCourtOutcomeCreator < ApplicationService
  GUILTY_VERDICTS = %w[GUILTY GUILTY_BUT_OF_ALTERNATIVE_OFFENCE_BY_JURY_CONVICTED GUILTY_BUT_OF_LESSER_OFFENCE_BY_JURY_CONVICTED GUILTY_BY_JURY_CONVICTED GUILTY_CONVICTED].freeze

  def initialize(defendant:)
    @defendant = defendant
  end

  def call
    {
      ccooOutcome: trial_outcome,
      caseEndDate: trial_end_date,
    }
  end

private

  def trial_outcome
    return "CONVICTED" if defendant[:offences]&.all? do |offence|
      GUILTY_VERDICTS.include? offence.dig(:verdict, :verdictType, :categoryType)
    end
    return "PART CONVICTED" if defendant[:offences]&.any? do |offence|
      GUILTY_VERDICTS.include? offence.dig(:verdict, :verdictType, :categoryType)
    end

    "AQUITTED" # This incorrect spelling is used in the MAAT database, and so must be used here to ensure compatibility
  end

  def trial_end_date
    defendant.dig(:offences, 0, :verdict, :verdictDate)
  end

  attr_reader :defendant
end
