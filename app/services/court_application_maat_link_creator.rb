class CourtApplicationMaatLinkCreator < ApplicationService
  attr_reader :laa_reference, :subject_id

  def initialize(subject_id, user_name, maat_reference)
    @laa_reference = LaaReference.new(
      defendant_id: subject_id,
      user_name:,
      maat_reference: maat_reference.presence || LaaReference.generate_linking_dummy_maat_reference,
    )
    @subject_id = subject_id
  end

  def call
    post_laa_references_to_common_platform!

    publish_laa_reference_to_queue unless laa_reference.dummy_maat_reference?
    fetch_past_hearings

    laa_reference.adjust_link_and_save!
  end

private

  def publish_laa_reference_to_queue
    maat_api_laa_reference = MaatApi::CourtApplicationLaaReference.new(
      maat_reference: laa_reference.maat_reference,
      user_name: laa_reference.user_name,
      court_application_summary:,
    )

    Sqs::MessagePublisher.call(
      message: MaatApi::LaaReferenceMessage.new(maat_api_laa_reference).generate,
      queue_url: Rails.configuration.x.aws.sqs_url_link,
      log_info: { maat_reference: laa_reference.maat_reference },
    )
  end

  def post_laa_references_to_common_platform!
    today = Time.zone.today.strftime("%Y-%m-%d")

    if court_application_summary.appeal?
      # Appeal has one or more offences
      offences.each do |offence|
        response = CommonPlatform::Api::RecordApplicationLaaReferenceForAppeal.call(
          application_id: court_application_summary.application_id,
          subject_id:,
          offence_id: offence&.offence_id,
          application_reference: laa_reference.maat_reference,
          status_code: "AP",
          status_date: today,
        )
        unless response.success?
          raise CommonPlatform::Api::Errors::FailedDependency, "Error posting to #{response&.env&.url}: #{response.body}"
        end
      end
    else
      # Breach/Poca has no offences
      response = CommonPlatform::Api::RecordApplicationLaaReferenceForBreach.call(
        application_id: court_application_summary.application_id,
        application_reference: laa_reference.maat_reference,
        status_code: "AP",
        status_date: today,
      )

      unless response.success?
        raise CommonPlatform::Api::Errors::FailedDependency, "Error posting to #{response&.env&.url}: #{response.body}"
      end
    end
  rescue CommonPlatform::Api::Errors::FailedDependency => e
    Sentry.capture_exception(
      e,
      tags: {
        request_id: Current.request_id,
        application_id: court_application_summary.application_id,
        maat_reference: laa_reference.maat_reference,
        user_name: laa_reference.user_name,
      },
    )
    raise e
  end

  def post_laa_reference_to_common_platform(offence = nil)
    response = CommonPlatform::Api::RecordCourtApplicationLaaReference.call(
      application_id: court_application_summary.application_id,
      subject_id:,
      offence_id: offence&.offence_id,
      status_code: "AP",
      application_reference: laa_reference.maat_reference,
      status_date: Time.zone.today.strftime("%Y-%m-%d"),
    )

    raise CommonPlatform::Api::Errors::FailedDependency, "Error posting LAA Reference to Common Platform" unless response.success?
  rescue StandardError => e
    record_and_reraise(e, offence)
  end

  def record_and_reraise(exception, offence = nil)
    Sentry.capture_exception(
      exception,
      tags: {
        request_id: Current.request_id,
        subject_id: subject_id,
        maat_reference: laa_reference.maat_reference,
        user_name: laa_reference.user_name,
        offence_id: offence&.offence_id,
      },
    )
    raise exception
  end

  def fetch_past_hearings
    court_application_summary.hearing_summary.each do |hearing_summary|
      HearingResultFetcherWorker.perform_at(
        30.seconds.from_now,
        Current.request_id,
        hearing_summary.id,
        nil,
        laa_reference.defendant_id,
      )
    end
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
end
