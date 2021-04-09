# frozen_string_literal: true

class HearingsCreator < ApplicationService
  def initialize(hearing_id:)
    @hearing_id = hearing_id
    @hearing_data = hearing_body[:hearing]
    @hearing = HmctsCommonPlatform::Hearing.new(hearing_body[:hearing])
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
    hearing.prosecution_cases.each do |prosecution_case|
      prosecution_case.defendants.each do |defendant|
        next if defendant.offences.any? { |o| o.laa_reference_application_reference&.start_with?("A", "Z") }

        maat_api_prosecution_case = MaatApi::ProsecutionCase.new(
          shared_time,
          LaaReference.find_by(defendant_id: defendant.id, linked: true).maat_reference,
          prosecution_case.urn,
          hearing,
          defendant,
        )

        Sqs::MessagePublisher.call(
          message: MaatApi::Message.new(maat_api_prosecution_case).generate,
          queue_url: Rails.configuration.x.aws.sqs_url_hearing_resulted,
        )
      end
    end
  end

  def push_appeals
    hearing_data[:courtApplications]&.each do |appeal|
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
    hearing_data[:courtApplications]&.each do |court_application_data|
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
                             court_centre_id: hearing_data[:courtCentre][:id],
                             appeal_data: appeal_data)
  end

  def jurisdiction_type
    @jurisdiction_type ||= hearing_data[:jurisdictionType]
  end

  attr_reader :shared_time, :hearing, :hearing_data
end
