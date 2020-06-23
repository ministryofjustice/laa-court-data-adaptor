# frozen_string_literal: true

class LaaReferenceUnlinker < ApplicationService
  def initialize(defendant_id:, user_name:, unlink_reason_code:, unlink_reason_text:)
    @defendant_id = defendant_id
    @user_name = user_name
    @unlink_reason_code = unlink_reason_code
    @unlink_reason_text = unlink_reason_text
    @maat_reference = offences.first.maat_reference unless offences.first.dummy_maat_reference?
  end

  def call
    push_to_sqs if maat_reference.present?
    call_cp_endpoint
  end

  private

  def push_to_sqs
    Sqs::PublishUnlinkLaaReference.call(maat_reference: maat_reference, user_name: user_name, unlink_reason_code: unlink_reason_code, unlink_reason_text: unlink_reason_text)
  end

  def call_cp_endpoint
    offences.each do |offence|
      Api::RecordLaaReference.call(
        prosecution_case_id: offence.prosecution_case_id,
        defendant_id: offence.defendant_id,
        offence_id: offence.offence_id,
        status_code: 'AP',
        application_reference: dummy_maat_reference,
        status_date: Time.zone.today.strftime('%Y-%m-%d')
      )
    end
  end

  def offences
    @offences ||= ProsecutionCaseDefendantOffence.where(defendant_id: defendant_id)
  end

  def dummy_maat_reference
    @dummy_maat_reference ||= "Z#{ActiveRecord::Base.connection.execute("SELECT nextval('dummy_maat_reference_seq')")[0]['nextval']}"
  end

  attr_reader :defendant_id, :maat_reference, :user_name, :unlink_reason_code, :unlink_reason_text
end
