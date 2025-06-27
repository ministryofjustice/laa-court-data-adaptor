class HearingRepullBatchCreator < ApplicationService
  def initialize(maat_ids)
    @maat_ids = maat_ids
  end

  def call
    cases_with_matching_maat_ids = retrieve_cases_with_matching_maat_ids

    batch = HearingRepullBatch.create!
    cases_with_matching_maat_ids.each do |case_with_ids|
      repull = ProsecutionCaseHearingRepull.create!(
        prosecution_case: case_with_ids[:prosecution_case],
        urn: case_with_ids[:prosecution_case].body["prosecutionCaseReference"],
        maat_ids: case_with_ids[:maat_ids].join(","),
        hearing_repull_batch: batch,
      )

      ProsecutionCaseHearingRepullWorker.perform_async(repull.id)
    end

    create_repull_for_missing_maat_ids(cases_with_matching_maat_ids, batch)

    batch
  end

private

  def retrieve_cases_with_matching_maat_ids
    references = LaaReference.where(linked: true, maat_reference: maat_list).to_a
    defendant_offences = ProsecutionCaseDefendantOffence.where(defendant_id: references.map(&:defendant_id)).to_a
    prosecution_cases = ProsecutionCase.where(id: defendant_offences.map(&:prosecution_case_id))
    cases_with_defendant_ids = prosecution_cases.map do |p_case|
      {
        prosecution_case: p_case,
        defendant_ids: defendant_offences.select { it.prosecution_case_id == p_case.id }.map(&:defendant_id).uniq,
      }
    end
    cases_with_defendant_ids.map do |case_and_ids|
      {
        prosecution_case: case_and_ids[:prosecution_case],
        maat_ids: references.select { it.defendant_id.in?(case_and_ids[:defendant_ids]) }.map(&:maat_reference),
      }
    end
  end

  def maat_list
    @maat_list ||= maat_ids.split(",").map { it.split("\n") }.flatten.map(&:strip).map(&:presence).compact
  end

  def create_repull_for_missing_maat_ids(cases_with_matching_maat_ids, batch)
    found_maat_ids = cases_with_matching_maat_ids.map { it[:maat_ids] }.flatten

    missing_maat_ids = maat_list - found_maat_ids

    return unless missing_maat_ids.any?

    ProsecutionCaseHearingRepull.create!(
      urn: "Unrecognised MAAT IDs",
      maat_ids: missing_maat_ids.join(","),
      hearing_repull_batch: batch,
      status: :complete,
    )
  end

  attr_reader :maat_ids
end
