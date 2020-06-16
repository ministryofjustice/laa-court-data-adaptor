# frozen_string_literal: true

class HearingsCreator < ApplicationService
  def initialize(shared_time:, hearing:)
    @shared_time = shared_time
    @hearing = hearing
  end

  def call
    push_prosecution_cases
    push_appeals
  end

  private

  def push_prosecution_cases
    hearing[:prosecutionCases]&.each do |prosecution_case|
      prosecution_case[:defendants].each do |defendant|
        next if defendant[:laaApplnReference][:applicationReference]&.start_with?('A', 'Z')

        push_to_sqs(shared_time: shared_time,
                    case_urn: prosecution_case[:prosecutionCaseIdentifier][:caseURN],
                    defendant: defendant,
                    appeal_data: nil)
      end
    end
  end

  def push_appeals
    hearing[:courtApplications]&.each do |appeal|
      defendant = appeal.dig(:applicant, :defendant)
      next if defendant[:laaApplnReference][:applicationReference]&.start_with?('A', 'Z')

      push_to_sqs(shared_time: shared_time,
                  case_urn: appeal[:applicationReference],
                  defendant: defendant,
                  appeal_data: {
                    appeal_type: appeal.dig(:type, :applicationCode),
                    appeal_outcome: appeal[:applicationOutcomes]
                  })
    end
  end

  def push_to_sqs(shared_time:, case_urn:, defendant:, appeal_data:)
    Sqs::PublishHearing.call(shared_time: shared_time,
                             jurisdiction_type: jurisdiction_type,
                             case_urn: case_urn,
                             defendant: defendant,
                             cjs_location: cjs_location,
                             appeal_data: appeal_data)
  end

  def jurisdiction_type
    @jurisdiction_type ||= hearing[:jurisdictionType]
  end

  def cjs_location
    @cjs_location ||= hearing.dig(:courtCentre, :ouCode)[0..4]
  end

  attr_reader :shared_time, :hearing
end
