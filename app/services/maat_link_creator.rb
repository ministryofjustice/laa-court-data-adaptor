# frozen_string_literal: true

class MaatLinkCreator < ApplicationService
  def initialize(laa_reference_id:)
    @laa_reference = LaaReference.find(laa_reference_id)
  end

  def call
    push_to_sqs unless laa_reference.dummy_maat_reference?
    call_cp_endpoint
    PastHearingsFetcherWorker.perform_at(30.seconds.from_now, Current.request_id, prosecution_case_id)
  end

  private

  def push_to_sqs
    Sqs::PublishLaaReference.call(defendant_id: laa_reference.defendant_id,
                                  prosecution_case_id: prosecution_case_id,
                                  user_name: laa_reference.user_name,
                                  maat_reference: laa_reference.maat_reference)
  end

  def call_cp_endpoint
    offences.each do |offence|
      Api::RecordLaaReference.call(
        prosecution_case_id: offence.prosecution_case_id,
        defendant_id: offence.defendant_id,
        offence_id: offence.offence_id,
        status_code: 'AP',
        application_reference: laa_reference.maat_reference,
        status_date: Time.zone.today.strftime('%Y-%m-%d')
      )
    end
  end

  def offences
    @offences ||= ProsecutionCaseDefendantOffence.where(defendant_id: laa_reference.defendant_id)
  end

  def prosecution_case_id
    @prosecution_case_id ||= offences.first.prosecution_case_id
  end

  attr_reader :laa_reference
end
