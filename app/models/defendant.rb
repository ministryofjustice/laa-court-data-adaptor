# frozen_string_literal: true

class Defendant
  include ActiveModel::Model

  attr_accessor :body, :details, :prosecution_case_id

  def id
    body["defendantId"]
  end

  def name
    [first_name, middle_name, last_name].compact.join(" ")
  end

  def first_name
    body["defendantFirstName"]
  end

  def middle_name
    body["defendantMiddleName"]
  end

  def last_name
    body["defendantLastName"]
  end

  def date_of_birth
    body["defendantDOB"]
  end

  def national_insurance_number
    body["defendantNINO"]
  end

  def arrest_summons_number
    body["defendantASN"]
  end

  def offences
    body["offenceSummary"].map { |offence| Offence.new(body: offence, details: offence_details[offence["offenceId"]]) }
  end

  def defence_organisation
    return unless representation_order_exists?

    DefenceOrganisation.new(body: case_reference.defence_organisation) if case_reference.defence_organisation.present?
  end

  def representation_order_date
    return unless representation_order_exists?

    case_reference&.status_date
  end

  def offence_ids
    offences.map(&:id)
  end

  def defence_organisation_id
    defence_organisation&.id
  end

  def maat_reference
    _maat_reference if valid_maat_reference?
  end

  def post_hearing_custody_statuses
    offence_details.deep_transform_keys(&:to_sym).flat_map do |_offence_id, offence|
      PostHearingCustodyCalculator.call(offences: offence)
    end
  end

  def prosecution_case
    ProsecutionCase.find_by(id: prosecution_case_id)
  end

private

  def offence_details
    return {} if details.blank?

    details.flat_map { |detail| detail["offences"] }.group_by { |offence| offence["id"] }
  end

  def valid_maat_reference?
    _maat_reference.present? && !_maat_reference.start_with?("Z")
  end

  def _maat_reference
    refs = offences.map(&:maat_reference).uniq.compact
    raise "Too many maat references" if refs.size > 1

    refs&.first
  end

  def representation_order_hash
    body["representationOrder"] if valid_maat_reference?
  end

  def representation_order_exists?
    representation_order_hash.present? && case_reference.present?
  end

  def case_reference
    @case_reference ||= ProsecutionCaseDefendantOffence.find_by(defendant_id: id)
  end
end
