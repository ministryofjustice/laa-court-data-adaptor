class CourtApplicationLaaReferenceUnlinker < ApplicationService
  def initialize(subject_id:, user_name:, unlink_reason_code:, unlink_other_reason_text:)
    @subject_id = subject_id
    @user_name = user_name
    @unlink_reason_code = unlink_reason_code
    @unlink_other_reason_text = unlink_other_reason_text

    @laa_reference = LaaReference.find_by(defendant_id: subject_id, linked: true)
  end

  def call
    return unless laa_reference

    push_to_queue unless laa_reference.dummy_maat_reference?
    update_offences_on_common_platform
    unlink_maat_reference!
  end

private

  def unlink_maat_reference!
    laa_reference.unlink!
  end

  def push_to_queue
    Sqs::MessagePublisher.call(
      message: {
        defendantId: subject_id,
        maatId: laa_reference.maat_reference,
        userId: user_name,
        reasonId: unlink_reason_code,
        otherReasonText: unlink_other_reason_text,
      },
      queue_url: Rails.configuration.x.aws.sqs_url_unlink,
      log_info: { maat_reference: laa_reference.maat_reference },
    )
  end

  def update_offences_on_common_platform
    offences.each { |offence| update_offence_on_common_platform(offence) }
  end

  def update_offence_on_common_platform(offence)
    CommonPlatform::Api::RecordCourtApplicationLaaReference.call(
      application_id: court_application_summary.application_id,
      subject_id:,
      offence_id: offence.offence_id,
      status_code: "AP",
      application_reference: dummy_maat_reference,
      status_date: Time.zone.today.strftime("%Y-%m-%d"),
    )
  end

  def offences
    @offences ||= CourtApplicationDefendantOffence.where(defendant_id: laa_reference.defendant_id)
  end

  def court_application_summary
    @court_application_summary ||= HmctsCommonPlatform::CourtApplicationSummary.new(offences.first.court_application.body)
  end

  def dummy_maat_reference
    @dummy_maat_reference ||= LaaReference.generate_unlinking_dummy_maat_reference
  end

  attr_reader :subject_id, :laa_reference, :user_name, :unlink_reason_code, :unlink_other_reason_text
end
