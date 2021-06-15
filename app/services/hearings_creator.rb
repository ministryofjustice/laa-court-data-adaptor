# frozen_string_literal: true

class HearingsCreator < ApplicationService
  attr_reader :hearing_resulted_data

  def initialize(hearing_resulted_data:)
    @hearing_resulted_data = hearing_resulted_data
  end

  def hearing_resulted
    # :nocov:
    if hearing_resulted_data.is_a?(String)
      hearing_id = hearing_resulted_data
      result = HmctsCommonPlatform::HearingResulted.new(Hearing.find(hearing_id).body)
    end
    # :nocov:

    if hearing_resulted_data.is_a?(Hash)
      result = HmctsCommonPlatform::HearingResulted.new(hearing_resulted_data)
    end

    result
  end

  def call
    push_prosecution_cases
    push_applications
  end

private

  def push_prosecution_cases
    hearing_resulted.hearing.prosecution_cases.each do |prosecution_case|
      prosecution_case.defendants.each do |defendant|
        next if defendant.offences.any? do |offence|
          LaaReference.new(maat_reference: offence.laa_reference_application_reference).dummy_maat_reference?
        end

        laa_reference = LaaReference.find_by(defendant_id: defendant.id, linked: true)

        next if laa_reference.blank?

        maat_api_prosecution_case = MaatApi::ProsecutionCase.new(
          hearing_resulted,
          prosecution_case.urn,
          defendant,
          laa_reference.maat_reference,
        )

        Sqs::MessagePublisher.call(
          message: MaatApi::Message.new(maat_api_prosecution_case).generate,
          queue_url: Rails.configuration.x.aws.sqs_url_hearing_resulted,
        )
      end
    end
  end

  def push_applications
    hearing_resulted.hearing.court_applications.each do |court_application|
      court_application.defendant_cases.each do |defendant_case|
        laa_reference = LaaReference.find_by(defendant_id: defendant_case.defendant_id, linked: true)

        next if laa_reference.blank?

        maat_api_court_application = MaatApi::CourtApplication.new(
          hearing_resulted,
          court_application,
          laa_reference.maat_reference,
        )

        Sqs::MessagePublisher.call(
          message: MaatApi::Message.new(maat_api_court_application).generate,
          queue_url: Rails.configuration.x.aws.sqs_url_hearing_resulted,
        )
      end
    end
  end
end
