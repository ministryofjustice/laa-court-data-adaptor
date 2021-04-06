# frozen_string_literal: true

class HearingsCreator < ApplicationService
  def initialize(hearing_id:)
    @hearing_id = hearing_id
    @hearing = hearing_body[:hearing]
    @shared_time = hearing_body[:sharedTime]
  end

  def hearing_body
    Hearing.find(@hearing_id).body.deep_symbolize_keys
  end

  def call
    push_prosecution_cases
    push_appeals
    push_applications
  end

private

  def push_prosecution_cases
    hearing[:prosecutionCases]&.each do |prosecution_case_data|
      prosecution_case_data[:defendants].each do |defendant_data|
        next if defendant_data[:offences].map { |offence| offence.dig(:laaApplnReference, :applicationReference)&.start_with?("A", "Z") }.any?

        laa_reference = LaaReference.find_by!(defendant_id: defendant_data[:id], linked: true)
        next if laa_reference.blank?

        prosecution_case = MaatApi::ProsecutionCase.new(
          hearing_body,
          prosecution_case_data[:prosecutionCaseIdentifier][:caseURN],
          defendant_data,
          laa_reference.maat_reference,
        )

        Sqs::MessagePublisher.call(
          message: MaatApi::Message.new(prosecution_case).generate,
          queue_url: Rails.configuration.x.aws.sqs_url_hearing_resulted,
        )
      end
    end
  end

  def push_appeals
    hearing[:courtApplications]&.each do |appeal|
      defendant = appeal.dig(:applicant, :defendant)

      next if defendant.nil?
      next if defendant[:offences].map { |offence| offence.dig(:laaApplnReference, :applicationReference)&.start_with?("A", "Z") }.any?

      push_to_sqs(shared_time: shared_time,
                  case_urn: appeal[:applicationReference],
                  defendant: defendant,
                  appeal_data: {
                    appeal_type: appeal.dig(:type, :applicationCode),
                    appeal_outcome: appeal[:applicationOutcomes],
                  })
    end
  end

  def push_applications
    hearing[:courtApplications]&.each do |court_application_data|
      defendant_cases = court_application_data.dig(:applicant, :masterDefendant, :defendantCase) || []

      defendant_cases.each do |defendant_case|
        laa_reference = LaaReference.find_by(defendant_id: defendant_case[:defendantId], linked: true)

        next if laa_reference.blank?

        court_application = MaatApi::CourtApplication.new(
          hearing_body,
          court_application_data,
          laa_reference.maat_reference,
        )

        Sqs::MessagePublisher.call(
          message: MaatApi::Message.new(court_application).generate,
          queue_url: Rails.configuration.x.aws.sqs_url_hearing_resulted,
        )
      end
    end
  end

  def push_to_sqs(shared_time:, case_urn:, defendant:, appeal_data:)
    Sqs::PublishHearing.call(shared_time: shared_time,
                             jurisdiction_type: jurisdiction_type,
                             case_urn: case_urn,
                             defendant: defendant,
                             court_centre_id: hearing[:courtCentre][:id],
                             appeal_data: appeal_data)
  end

  def jurisdiction_type
    @jurisdiction_type ||= hearing[:jurisdictionType]
  end

  attr_reader :shared_time, :hearing
end
