# frozen_string_literal: true

class HearingsCreator < ApplicationService
  def initialize(hearing_id:)
    @hearing_id = hearing_id
    @hearing = hearing_body[:hearing]
    @shared_time = hearing_body[:sharedTime]
  end

  # This is temp to process failing delayed jobs. To be reverted. See PR
  def hearing_body
    body = Hearing.find(@hearing_id).body

    if body.is_a?(Hash)
      return body.deep_symbolize_keys
    end

    if body.is_a?(String)
      JSON.parse(body).deep_symbolize_keys
    end
  end

  def call
    push_prosecution_cases
    push_applications
  end

private

  def push_prosecution_cases
    hearing[:prosecutionCases]&.each do |prosecution_case|
      prosecution_case[:defendants].each do |defendant|
        next if defendant[:offences].map { |offence| offence.dig(:laaApplnReference, :applicationReference)&.start_with?("A", "Z") }.any?

        push_to_sqs(shared_time: shared_time,
                    case_urn: prosecution_case[:prosecutionCaseIdentifier][:caseURN],
                    defendant: defendant,
                    application_data: nil)
      end
    end
  end

  def push_applications
    hearing[:courtApplications]&.each do |application|
      defendant_cases = application.dig(:applicant, :masterDefendant, :defendantCase)
      return if defendant_cases.nil?

      defendant_cases.each do |defendant_case|
        defendant = LaaReference.find_by(defendant_id: defendant_case[:defendantId], linked: true)
        next if defendant.nil?

        push_to_sqs(shared_time: shared_time,
                    case_urn: application[:applicationReference],
                    defendant: defendant,
                    application_data: application)
      end
    end
  end

  def push_to_sqs(shared_time:, case_urn:, defendant:, application_data:)
    Sqs::PublishHearing.call(shared_time: shared_time,
                             jurisdiction_type: jurisdiction_type,
                             case_urn: case_urn,
                             defendant: defendant,
                             court_centre_id: hearing[:courtCentre][:id],
                             application_data: application_data)
  end

  def jurisdiction_type
    @jurisdiction_type ||= hearing[:jurisdictionType]
  end

  attr_reader :shared_time, :hearing
end
