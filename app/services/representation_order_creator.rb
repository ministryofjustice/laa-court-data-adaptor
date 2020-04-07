# frozen_string_literal: true

class RepresentationOrderCreator < ApplicationService
  def initialize(defendant_id:, offences:, maat_reference:, defence_organisation:)
    @offences = offences.map(&:with_indifferent_access)
    @maat_reference = maat_reference
    @defendant_id = defendant_id
    @defence_organisation = defence_organisation.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
  end

  def call
    call_cp_endpoint
  end

  private

  def call_cp_endpoint
    offences.each do |offence|
      prosecution_case = ProsecutionCaseDefendantOffence.find_by!(defendant_id: defendant_id, offence_id: offence[:offence_id])

      Api::RecordRepresentationOrder.call(
        prosecution_case_id: prosecution_case.prosecution_case_id,
        defendant_id: defendant_id,
        offence_id: offence[:offence_id],
        status_code: offence[:status_code],
        application_reference: maat_reference,
        status_date: offence[:status_date],
        effective_start_date: offence[:effective_start_date],
        effective_end_date: offence[:effective_end_date],
        defence_organisation: defence_organisation
      )
    end
  end

  attr_reader :defendant_id, :offences, :maat_reference, :defence_organisation
end
