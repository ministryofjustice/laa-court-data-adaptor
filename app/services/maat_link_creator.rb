# frozen_string_literal: true

class MaatLinkCreator < ApplicationService
  def initialize(laa_reference_id:)
    @laa_reference = LaaReference.find(laa_reference_id)
  end

  def call
    publish_laa_reference_to_queue unless laa_reference.dummy_maat_reference?
    post_laa_references_to_common_platform
    fetch_past_hearings
  end

private

  def publish_laa_reference_to_queue
    Sqs::PublishLaaReference.call(defendant_id: laa_reference.defendant_id,
                                  prosecution_case_id: prosecution_case_id,
                                  user_name: laa_reference.user_name,
                                  maat_reference: laa_reference.maat_reference)
  end

  def post_laa_references_to_common_platform
    offences.each { |offence| post_laa_reference_to_common_platform(offence) }
  end

  def post_laa_reference_to_common_platform(offence)
    Api::RecordLaaReference.call(
      prosecution_case_id: offence.prosecution_case_id,
      defendant_id: offence.defendant_id,
      offence_id: offence.offence_id,
      status_code: "AP",
      application_reference: laa_reference.maat_reference,
      status_date: Time.zone.today.strftime("%Y-%m-%d"),
    )
  end

  def fetch_past_hearings
    PastHearingsFetcherWorker.perform_at(30.seconds.from_now,
                                         Current.request_id,
                                         prosecution_case_id)
  end

  def offences
    @offences ||= ProsecutionCaseDefendantOffence.where(defendant_id: laa_reference.defendant_id)
  end

  def prosecution_case_id
    @prosecution_case_id ||= offences.first.prosecution_case_id
  end

  attr_reader :laa_reference
end
