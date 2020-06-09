# frozen_string_literal: true

class CrownCourtOutcomeCreator < ApplicationService
  GUILTY_VERDICTS = %w[GUILTY_BUT_OF_LESSER_OFFENCE_BY_JURY_CONVICTED
                       GUILTY_CONVICTED
                       GUILTY_BY_JURY_CONVICTED
                       GUILTY_BUT_OF_LESSER_OFFENCE_CONVICTED].freeze

  def initialize(defendant:)
    @defendant = defendant
  end

  def call
    return unless result_is_a_conclusion?

    {
      ccooOutcome: trial_outcome,
      caseEndDate: case_end_date,
      appealType: nil
    }
  end

  private

  def result_is_a_conclusion?
    defendant.dig(:offences)&.any? { |offence| offence.dig(:verdict).present? }
  end

  def trial_outcome
    return 'CONVICTED' if defendant.dig(:offences)&.all? do |offence|
      GUILTY_VERDICTS.include? offence.dig(:verdict, :verdictType, :categoryType)
    end
    return 'PART CONVICTED' if defendant.dig(:offences)&.any? do |offence|
      GUILTY_VERDICTS.include? offence.dig(:verdict, :verdictType, :categoryType)
    end

    'AQUITTED' # This incorrect spelling is used in the MAAT database, and so must be used here to ensure compatibility
  end

  def case_end_date
    defendant.dig(:offences, 0, :verdict, :verdictDate)
  end

  attr_reader :defendant
end
