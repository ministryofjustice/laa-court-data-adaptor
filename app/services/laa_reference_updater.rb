# frozen_string_literal: true

class LaaReferenceUpdater < ApplicationService
  def initialize(contract)
    @contract = contract
  end

  def call
    ProsecutionCaseDefendantOffence.where(defendant_id: contract[:defendant_id]).each do |offence|
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

  private

  def maat_reference
    @maat_reference ||= contract[:maat_reference].presence || dummy_maat_reference
  end

  def dummy_maat_reference
    "A#{ActiveRecord::Base.connection.execute("SELECT nextval('dummy_maat_reference_seq')")[0]['nextval']}"
  end

  attr_reader :contract
end
