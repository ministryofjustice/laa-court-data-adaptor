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
        push_prosecution_case_message(defendant, prosecution_case, hearing_resulted)
      end
    end
  end

  def push_prosecution_case_message(defendant, prosecution_case, hearing_resulted)
    laa_reference = laa_references[defendant.id]

    return if laa_reference.blank? || laa_reference.dummy_maat_reference?

        maat_api_prosecution_case = MaatApi::ProsecutionCase.new(
          hearing_resulted,
          prosecution_case.urn,
          defendant,
          laa_reference.maat_reference,
          prosecution_case.is_civil,
        )

    publish_message(maat_api_prosecution_case, laa_reference)
  end

  def push_applications
    hearing_resulted.hearing.court_applications.each do |court_application|
      push_messages_about_defendants(court_application, hearing_resulted)
      push_message_about_subject(court_application, hearing_resulted)
    end
  end

  def push_messages_about_defendants(court_application, hearing_resulted)
    court_application.defendant_cases.each do |defendant_case|
      push_court_application_message(defendant_case.defendant_id, court_application, hearing_resulted)
    end
  end

  def push_message_about_subject(court_application, hearing_resulted)
    push_court_application_message(court_application.subject_id, court_application, hearing_resulted)
  end

  def push_court_application_message(defendant_id, court_application, hearing_resulted)
    laa_reference = laa_references[defendant_id]

    return if laa_reference.blank?

    maat_api_court_application = MaatApi::CourtApplication.new(
      hearing_resulted,
      court_application,
      laa_reference.maat_reference,
    )

    publish_message(maat_api_court_application, laa_reference)
  end

  def publish_message(maat_api_court_application, laa_reference)
    Sqs::MessagePublisher.call(
      message: MaatApi::Message.new(maat_api_court_application).generate,
      queue_url:,
      log_info: { maat_reference: laa_reference.maat_reference },
    )
  end

  def laa_references
    @laa_references ||= begin
      defendant_ids = [
        hearing_resulted.hearing.prosecution_cases.flat_map(&:defendants).map(&:id),
        hearing_resulted.hearing.court_applications.flat_map(&:defendant_cases).map(&:defendant_id),
        hearing_resulted.hearing.court_applications.map(&:subject_id),
      ].flatten

      LaaReference.where(defendant_id: defendant_ids, linked: true).index_by(&:defendant_id)
    end
  end
end
