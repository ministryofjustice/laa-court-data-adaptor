class CourtApplicationLaaReferenceUnlinker < ApplicationService
  def initialize(subject_id:, user_name:, unlink_reason_code:, unlink_other_reason_text:, maat_reference: nil)
    @subject_id = subject_id
    @user_name = user_name
    @unlink_reason_code = unlink_reason_code
    @unlink_other_reason_text = unlink_other_reason_text

    @laa_reference = LaaReference.retrieve_by_defendant_id_and_optional_maat_reference(subject_id, maat_reference)
  end

  def call
    push_to_queue unless laa_reference.dummy_maat_reference?
    update_offences_on_common_platform
    unlink_maat_reference!
  end

private

  def unlink_maat_reference!
    laa_reference.unlink!(unlink_reason_code:)
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
    if court_application_summary.subject_summary.has_offences?
      offences.each { |offence| update_laa_reference_on_common_platform!(offence) }
    else
      update_laa_reference_on_common_platform!
    end
  end

  def update_laa_reference_on_common_platform!(offence = nil)
    response = CommonPlatform::Api::RecordCourtApplicationLaaReference.call(
      application_id: court_application_summary.application_id,
      subject_id:,
      offence_id: offence&.offence_id,
      status_code: "AP",
      application_reference: dummy_maat_reference,
      status_date: Time.zone.today.strftime("%Y-%m-%d"),
    )

    raise CommonPlatform::Api::Errors::FailedDependency, "Error posting LAA Reference to Common Platform" unless response.success?
  end

  def offences
    @offences ||= court_application_summary.subject_summary.offence_summary
  end

  def court_application_summary
    @court_application_summary ||= HmctsCommonPlatform::CourtApplicationSummary.new(court_application.body)
  end

  def court_application
    @court_application ||= CourtApplication.find_by(subject_id: laa_reference.defendant_id)
  end

  def dummy_maat_reference
    @dummy_maat_reference ||= LaaReference.generate_unlinking_dummy_maat_reference
  end

  attr_reader :subject_id, :laa_reference, :user_name, :unlink_reason_code, :unlink_other_reason_text
end
