# frozen_string_literal: true

class ProsecutionCaseLinkValidator < ApplicationService
  def initialize(defendant_id:)
    @prosecution_case = ProsecutionCaseDefendantOffence.find_by(defendant_id:)&.prosecution_case
  end

  def call
    if @prosecution_case&.hearing_summaries.blank?
      message = "#{self.class.name} - prosecution_case: #{@prosecution_case ? 'present' : 'nil'} - hearing_summaries: empty!"
      Rails.logger.error(message)
      Sentry.capture_message(message)

      return false
    end

    true
  end
end
