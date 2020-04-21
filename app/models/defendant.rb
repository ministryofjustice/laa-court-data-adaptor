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

  def offence_ids
    offences.map(&:id)
  end

  def maat_reference
    _maat_reference unless _maat_reference&.start_with?('Z')
  end

  private

  def _maat_reference
    refs = offences.map(&:maat_reference).uniq.compact
    raise 'Too many maat references' if refs.size > 1

    refs&.first
  end
end
