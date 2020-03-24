# frozen_string_literal: true

class LaaReferenceUnlinker < ApplicationService
  def initialize(defendant_id:)
    @defendant_id = defendant_id
  end

  def call
    call_cp_endpoint
  end

  private

  def call_cp_endpoint
    offences.each do |offence|
      Api::RecordLaaReference.call(
        prosecution_case_id: offence.prosecution_case_id,
        defendant_id: offence.defendant_id,
        offence_id: offence.offence_id,
        status_code: 'AP',
        application_reference: dummy_maat_reference,
        status_date: Date.today.strftime('%Y-%m-%d')
      )
    end
  end

  def offences
    @offences ||= ProsecutionCaseDefendantOffence.where(defendant_id: defendant_id)
  end

  def dummy_maat_reference
    @dummy_maat_reference ||= "Z#{ActiveRecord::Base.connection.execute("SELECT nextval('dummy_maat_reference_seq')")[0]['nextval']}"
  end

  attr_reader :defendant_id
end
