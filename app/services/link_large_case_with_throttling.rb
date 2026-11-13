# frozen_string_literal: true

class LinkLargeCaseWithThrottling < ApplicationService
  OFFENCE_LINKING_DELAY = 1.second

  attr_reader :maat_reference, :user_name, :prosecution_case_urn, :laa_reference, :defendant_id, :prosecution_case_id

  def initialize(maat_reference:, user_name:, prosecution_case_urn:)
    @maat_reference = maat_reference
    @user_name = user_name
    @prosecution_case_urn = prosecution_case_urn
    @laa_reference = nil
    @defendant_id = nil
    @prosecution_case_id = nil
  end

  def call
    find_prosecution_case_and_defendant
    create_laa_reference
    link_offences_to_common_platform_with_throttling
    publish_to_maat_queue
    mark_as_linked
    log_success
  end

private

  def find_prosecution_case_and_defendant
    # Find prosecution case by URN
    prosecution_case = ProsecutionCase.where("body->>'prosecutionCaseReference' = ?", prosecution_case_urn).first
    raise "Prosecution case not found for URN #{prosecution_case_urn}" unless prosecution_case.present?

    @prosecution_case_id = prosecution_case.id

    # Get the first defendant from the case - in reality there's typically one per case linking operation
    defendants = ProsecutionCaseDefendantOffence.where(prosecution_case_id:).distinct.pluck(:defendant_id)
    raise "No defendants found for case #{prosecution_case_urn}" if defendants.empty?

    @defendant_id = defendants.first
  end

  def create_laa_reference
    @laa_reference = LaaReference.new(
      defendant_id:,
      user_name:,
      maat_reference:,
    )
  end

  def link_offences_to_common_platform_with_throttling
    offences = offences_for_defendant
    offence_count = offences.count

    Rails.logger.info "[INFO - #{Time.zone.now}] Linking #{offence_count} offences to Common Platform with #{OFFENCE_LINKING_DELAY.to_i}s delay between each..."

    offences.each_with_index do |offence, index|
      link_single_offence(offence)
      Rails.logger.info "[INFO - #{Time.zone.now}] Linked offence #{index + 1}/#{offence_count} (ID: #{offence.offence_id})"

      # Apply delay between requests (but not after the last one)
      sleep(OFFENCE_LINKING_DELAY.to_f) unless index == offence_count - 1
    rescue StandardError => e
      Sentry.capture_exception(
        e,
        tags: {
          request_id: Current.request_id,
          defendant_id:,
          maat_reference:,
          user_name:,
          offence_id: offence.offence_id,
          operation: "link_large_case",
        },
      )
      raise e
    end

    Rails.logger.info "[INFO - #{Time.zone.now}] Successfully linked all #{offence_count} offences"
  end

  def link_single_offence(offence)
    response = CommonPlatform::Api::RecordProsecutionCaseLaaReference.call(
      case_defendant_offence: offence,
      defendant_id: offence.defendant_id,
      offence_id: offence.offence_id,
      status_code: "AP",
      application_reference: maat_reference,
      status_date: Time.zone.today.strftime("%Y-%m-%d"),
    )

    unless response.success?
      raise CommonPlatform::Api::Errors::FailedDependency.from_response(
        service: self.class.name,
        response:,
        context: "posting LAA Reference for offence #{offence.offence_id}",
      )
    end
  end

  def publish_to_maat_queue
    Rails.logger.info "[INFO - #{Time.zone.now}] Publishing link notification to MAAT queue..."

    maat_api_laa_reference = MaatApi::LaaReference.new(
      maat_reference:,
      user_name:,
      defendant_summary:,
      prosecution_case_summary:,
      can_update_laa_status: false,
    )

    Sqs::MessagePublisher.call(
      message: MaatApi::LaaReferenceMessage.new(maat_api_laa_reference).generate,
      queue_url: Rails.configuration.x.aws.sqs_url_link,
      log_info: { maat_reference: },
    )

    Rails.logger.info "[INFO - #{Time.zone.now}] Published link notification to MAAT queue"
  end

  def mark_as_linked
    laa_reference.link!
  end

  def log_success
    Rails.logger.info "[SUCCESS - #{Time.zone.now}] Case #{prosecution_case_urn} successfully linked to MAAT ID #{maat_reference}"
  end

  def offences_for_defendant
    ProsecutionCaseDefendantOffence.where(defendant_id:)
  end

  def defendant_summary
    prosecution_case_summary.defendant_summaries.find { |d| d.defendant_id == defendant_id }
  end

  def prosecution_case_summary
    @prosecution_case_summary ||= HmctsCommonPlatform::ProsecutionCaseSummary.new(prosecution_case_summary_data)
  end

  def prosecution_case_summary_data
    @prosecution_case_summary_data ||= ProsecutionCase.find(prosecution_case_id).body
  end
end
