# frozen_string_literal: true

class Defendant
  include ActiveModel::Model

  attr_accessor :body, :details, :prosecution_case_id

  def id
    body["defendantId"]
  end

  def name
    [first_name, middle_name, last_name].join(" ").squish
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
    return if case_reference.blank?

    DefenceOrganisation.new(body: case_reference.defence_organisation) if case_reference.defence_organisation.present?
  end

  def offence_ids
    offences.map(&:id)
  end

  def defence_organisation_id
    defence_organisation&.id
  end

  def judicial_result_ids
    judicial_results.map(&:id)
  end

  def judicial_results
    judicial_results_array.map do |judicial_result_data|
      HmctsCommonPlatform::JudicialResult.new(judicial_result_data)
    end
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

  def offence_history
    {
      defendant_id: id,
      offence_histories: offences.map do |offence|
        { id: offence.id, pleas: offence.pleas, mode_of_trial_reasons: offence.mode_of_trial_reasons }
      end,
    }
  end

private

  def offence_details
    return {} if details.blank?

    details.flat_map { |detail| detail["offences"] }.group_by { |offence| offence["id"] }
  end

  def judicial_results_array
    return [] if details.blank?

    details.flat_map { |detail| detail["judicialResults"] }.uniq.compact
  end

  def valid_maat_reference?
    _maat_reference.present? && !_maat_reference.start_with?("Z")
  end

  def _maat_reference
    LaaReference.find_by(defendant_id: id, linked: true)&.maat_reference
  end

  def case_reference
    @case_reference ||= ProsecutionCaseDefendantOffence.find_by(defendant_id: id)
  end
end
