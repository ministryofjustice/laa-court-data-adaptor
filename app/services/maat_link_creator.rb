# frozen_string_literal: true

class MaatLinkCreator < ApplicationService
  attr_reader :laa_reference, :defendant_id

  def initialize(defendant_id, user_name, maat_reference)
    @laa_reference = LaaReference.new(
      defendant_id: defendant_id,
      user_name: user_name,
      maat_reference: maat_reference.presence || LaaReference.generate_linking_dummy_maat_reference,
    )
    @defendant_id = defendant_id
  end

  def call
    post_laa_references_to_common_platform
    publish_laa_reference_to_queue unless laa_reference.dummy_maat_reference?
    fetch_past_hearings

    laa_reference.adjust_link_and_save!
  end

private

  def publish_laa_reference_to_queue
    maat_api_laa_reference = MaatApi::LaaReference.new(
      maat_reference: laa_reference.maat_reference,
      user_name: laa_reference.user_name,
      defendant_summary: defendant_summary,
      prosecution_case_summary: prosecution_case_summary,
    )

    Sqs::MessagePublisher.call(
      message: MaatApi::LaaReferenceMessage.new(maat_api_laa_reference).generate,
      queue_url: Rails.configuration.x.aws.sqs_url_link,
      log_info: { maat_reference: laa_reference.maat_reference },
    )
  end

  def post_laa_references_to_common_platform
    offences.each do |offence|
      post_laa_reference_to_common_platform(offence)
    rescue StandardError => e
      Sentry.capture_exception(
        e,
        tags: {
          request_id: Current.request_id,
          defendant_id: offence.defendant_id,
          maat_reference: laa_reference.maat_reference,
          user_name: laa_reference.user_name,
          offence_id: offence.offence_id,
        },
      )
      raise e
    end
  end

  def post_laa_reference_to_common_platform(offence)
    response = CommonPlatform::Api::RecordLaaReference.call(
      prosecution_case_id: offence.prosecution_case_id,
      defendant_id: offence.defendant_id,
      offence_id: offence.offence_id,
      status_code: "AP",
      application_reference: laa_reference.maat_reference,
      status_date: Time.zone.today.strftime("%Y-%m-%d"),
    )

    raise StandardError, "Error posting LAA Reference to Common Platform" unless response.success?
  end

  def fetch_past_hearings
    hearing_summaries.each do |hearing_summary|
      hearing_summary.hearing_days.each do |hearing_day|
        HearingResultFetcherWorker.perform_at(
          30.seconds.from_now,
          Current.request_id,
          hearing_summary.id,
          hearing_day.sitting_day,
          defendant_id,
        )
      end
    end
  end

  def hearing_summaries
    Array(ProsecutionCase.find(prosecution_case_id).body["hearingSummary"]).map do |hearing_summary_data|
      HmctsCommonPlatform::HearingSummary.new(hearing_summary_data)
    end
  end

  def defendant_summary
    prosecution_case_summary.defendant_summaries.find { |d| d.defendant_id == laa_reference.defendant_id }
  end

  def prosecution_case_summary
    HmctsCommonPlatform::ProsecutionCaseSummary.new(prosecution_case_summary_data)
  end

  def prosecution_case_summary_data
    @prosecution_case_summary_data ||= ProsecutionCase.find(prosecution_case_id).body
  end

  def prosecution_case_id
    @prosecution_case_id ||= offences.first.prosecution_case_id
  end

  def offences
    @offences ||= ProsecutionCaseDefendantOffence.where(defendant_id: laa_reference.defendant_id)
  end
end
