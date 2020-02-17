# frozen_string_literal: true

class LaaReferenceUpdater < ApplicationService
  def initialize(contract)
    @contract = contract
  end

  def call
    @maat_reference = contract[:maat_reference] || dummy_maat_reference

    ProsecutionCaseDefendantOffence.where(defendant_id: contract[:defendant_id]).each do |offence|
      @response = Api::RecordLaaReference.call(
        prosecution_case_id: offence.prosecution_case_id,
        defendant_id: offence.defendant_id,
        offence_id: offence.offence_id,
        status_code: 'AP',
        application_reference: @maat_reference,
        status_date: Date.today.strftime('%Y-%m-%d')
      )

      update_record(offence)
    end
  end

  private

  def dummy_maat_reference
    "A#{ActiveRecord::Base.connection.execute("SELECT nextval('dummy_maat_reference_seq')")[0]['nextval']}"
  end

  def update_record(offence)
    offence.maat_reference = @maat_reference
    offence.dummy_maat_reference = (@maat_reference.to_s[0] == 'A')
    offence.response_status = @response.status
    offence.response_body = @response.body
    offence.save!
  end

  attr_reader :contract
end
