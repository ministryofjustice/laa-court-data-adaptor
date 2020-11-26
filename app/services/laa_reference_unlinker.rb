# frozen_string_literal: true

class LaaReferenceUnlinker < ApplicationService
  def initialize(defendant_id:, user_name:, unlink_reason_code:, unlink_other_reason_text:)
    @defendant_id = defendant_id
    @user_name = user_name
    @unlink_reason_code = unlink_reason_code
    @unlink_other_reason_text = unlink_other_reason_text
    @laa_reference = LaaReference.find_by(defendant_id: defendant_id, linked: true)
  end

  def call
    unlink_current_maat_reference
    push_to_sqs unless laa_reference.dummy_maat_reference?
    call_cp_endpoint
  end

private

  def unlink_current_maat_reference
    laa_reference.update!(linked: false)
  end

  def push_to_sqs
    Sqs::PublishUnlinkLaaReference.call(
      maat_reference: laa_reference.maat_reference,
      user_name: user_name,
      unlink_reason_code: unlink_reason_code,
      unlink_other_reason_text: unlink_other_reason_text,
    )
  end

  def call_cp_endpoint
    offences.each do |offence|
      Api::RecordLaaReference.call(
        prosecution_case_id: offence.prosecution_case_id,
        defendant_id: offence.defendant_id,
        offence_id: offence.offence_id,
        status_code: "AP",
        application_reference: dummy_maat_reference,
        status_date: Time.zone.today.strftime("%Y-%m-%d"),
      )
    end
  end

  def offences
    @offences ||= ProsecutionCaseDefendantOffence.where(defendant_id: defendant_id)
  end

  def dummy_maat_reference
    @dummy_maat_reference ||= "Z#{ActiveRecord::Base.connection.execute("SELECT nextval('dummy_maat_reference_seq')")[0]['nextval']}"
  end

  attr_reader :defendant_id, :laa_reference, :user_name, :unlink_reason_code, :unlink_other_reason_text
end
