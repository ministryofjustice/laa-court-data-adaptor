# frozen_string_literal: true

class LaaReferenceCreator < ApplicationService
  def initialize(defendant_id:, maat_reference: nil)
    @defendant_id = defendant_id
    @maat_reference = maat_reference.presence || dummy_maat_reference
  end

  def call
    push_to_sqs unless dummy_reference?
    call_cp_endpoint
  end

  private

  def push_to_sqs
    Sqs::PublishLaaReference.call(defendant_id: defendant_id, prosecution_case_id: prosecution_case_id, maat_reference: maat_reference)
  end

  def call_cp_endpoint
    offences.each do |offence|
      Api::RecordLaaReference.call(
        prosecution_case_id: offence.prosecution_case_id,
        defendant_id: offence.defendant_id,
        offence_id: offence.offence_id,
        status_code: 'AP',
        application_reference: maat_reference,
        status_date: Date.today.strftime('%Y-%m-%d')
      )
    end
  end

  def offences
    @offences ||= ProsecutionCaseDefendantOffence.where(defendant_id: defendant_id)
  end

  def prosecution_case_id
    @prosecution_case_id ||= offences.first.prosecution_case_id
  end

  def dummy_maat_reference
    @dummy_maat_reference ||= "A#{ActiveRecord::Base.connection.execute("SELECT nextval('dummy_maat_reference_seq')")[0]['nextval']}"
  end

  def dummy_reference?
    @dummy_maat_reference.present?
  end

  attr_reader :defendant_id, :maat_reference
end
