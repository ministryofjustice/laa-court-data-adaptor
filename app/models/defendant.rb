# frozen_string_literal: true

class Defendant
  include ActiveModel::Model

  attr_accessor :body

  def id
    body['defendantId']
  end

  def name
    body['defendantName']
  end

  def date_of_birth
    body['defendantDOB']
  end

  def national_insurance_number
    body['defendantNINO']
  end

  def arrest_summons_number
    body['defendantASN']
  end

  def offences
    body['offenceSummary'].map { |offence| Offence.new(body: offence) }
  end

  def representation_order
    return unless representation_order_hash.present?

    {
      effective_from_date: representation_order_hash['effectiveFromDate'],
      effective_to_date: representation_order_hash['effectiveToDate'],
      laa_contract_number: representation_order_hash['laaContractNumber'],
      status_date: case_reference&.status_date,
      provider: case_reference&.defence_organisation
    }
  end

  def offence_ids
    offences.map(&:id)
  end

  def maat_reference
    _maat_reference if valid_maat_reference?
  end

  private

  def valid_maat_reference?
    _maat_reference.present? && !_maat_reference.start_with?('Z')
  end

  def _maat_reference
    refs = offences.map(&:maat_reference).uniq.compact
    raise 'Too many maat references' if refs.size > 1

    refs&.first
  end

  def representation_order_hash
    body['representationOrder'] if valid_maat_reference?
  end

  def case_reference
    @case_reference ||= ProsecutionCaseDefendantOffence.find_by(defendant_id: id)
  end
end
