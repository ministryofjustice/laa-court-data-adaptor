# frozen_string_literal: true

class MaatLinkMessageSender < ApplicationService
  def initialize(defendant_id:, user_name:, maat_reference:, court_centre_id:, oucode:)
    @defendant_id = defendant_id
    @user_name = user_name
    @maat_reference = maat_reference
    @court_centre_id = court_centre_id
    @oucode = oucode
  end

  def call
    validate_inputs
    publish_message_to_queue
  end

private

  attr_reader :defendant_id, :user_name, :maat_reference, :court_centre_id, :oucode

  def validate_inputs
    raise ArgumentError, "defendant_id is required" if defendant_id.blank?
    raise ArgumentError, "user_name is required" if user_name.blank?
    raise ArgumentError, "maat_reference is required" if maat_reference.blank?
    raise ArgumentError, "court_centre_id is required" if court_centre_id.blank?
    raise ArgumentError, "oucode is required" if oucode.blank?
    raise ArgumentError, "Defendant not found for ID: #{defendant_id}" if offences.empty?
  end

  def publish_message_to_queue
    maat_api_laa_reference = MaatApi::LaaReference.new(
      prosecution_case_summary:,
      defendant_summary:,
      user_name:,
      maat_reference:,
    )

    Sqs::MessagePublisher.call(
      message: MaatApi::LaaReferenceMessage.new(maat_api_laa_reference).generate,
      queue_url: Rails.configuration.x.aws.sqs_url_link,
      log_info: { maat_reference: },
    )
  end

  def defendant_summary
    prosecution_case_summary.defendant_summaries.find { |d| d.defendant_id == defendant_id }
  end

  def prosecution_case_summary
    HmctsCommonPlatform::ProsecutionCaseSummary.new(prosecution_case_summary_data)
  end

  def prosecution_case_summary_data
    body = ProsecutionCase.find(prosecution_case_id).body.deep_dup
    update_court_centre_code(body)
    body
  end

  def update_court_centre_code(body)
    Array(body["hearingSummary"]).each do |hs|
      cc = hs["courtCentre"]
      cc["code"] = oucode if cc && cc["id"] == court_centre_id && cc["code"].blank?
    end
  end

  def prosecution_case_id
    @prosecution_case_id ||= begin
      case_ids = offences.pluck(:prosecution_case_id).uniq
      raise ArgumentError, "Defendant found in multiple prosecution cases" if case_ids.count > 1

      case_ids.first
    end
  end

  def offences
    @offences ||= ProsecutionCaseDefendantOffence.where(defendant_id:)
  end
end
