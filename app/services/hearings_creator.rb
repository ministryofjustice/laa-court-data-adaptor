# frozen_string_literal: true

class HearingsCreator < ApplicationService
  attr_reader :hearing_resulted, :queue_url

  def initialize(hearing_resulted_data:, queue_url:)
    @hearing_resulted = HmctsCommonPlatform::HearingResulted.new(hearing_resulted_data)
    @queue_url = queue_url
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
          LaaReference.new(maat_reference: offence.laa_application_reference).dummy_maat_reference?
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
          queue_url:,
          log_info: { maat_reference: laa_reference.maat_reference },
        )
      end
    end
  end

  def push_applications
    hearing_resulted.hearing.court_applications.each do |court_application|
      push_messages_about_defendants(court_application, hearing_resulted)
      push_message_about_subject(court_application, hearing_resulted)
    end
  end

  def push_messages_about_defendants(court_application, hearing_resulted)
    court_application.defendant_cases.each do |defendant_case|
      laa_reference = LaaReference.find_by(defendant_id: defendant_case.defendant_id, linked: true)

      push_court_application_message(laa_reference, court_application, hearing_resulted)
    end
  end

  def push_message_about_subject(court_application, hearing_resulted)
    laa_reference = LaaReference.find_by(defendant_id: court_application.subject_id, linked: true)

    push_court_application_message(laa_reference, court_application, hearing_resulted)
  end

  def push_court_application_message(laa_reference, court_application, hearing_resulted)
    return if laa_reference.blank?

    maat_api_court_application = MaatApi::CourtApplication.new(
      hearing_resulted,
      court_application,
      laa_reference.maat_reference,
    )

    Sqs::MessagePublisher.call(
      message: MaatApi::Message.new(maat_api_court_application).generate,
      queue_url:,
      log_info: { maat_reference: laa_reference.maat_reference },
    )
  end
end
