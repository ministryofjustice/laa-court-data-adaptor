# frozen_string_literal: true

class CourtApplicationRecorder < ApplicationService
  def initialize(court_application_id, model)
    @prosecution_case = ProsecutionCase.find_or_initialize_by(id: court_application_id)
    @model = model
  end

  def call
    # Yes, court applications are not prosecution cases, but the prosecution_cases
    # table is where we are storing court application payloads, for reasons.
    prosecution_case.update!(body: model.data)

    model.subject_summary.offence_summary.each do |offence|
      ProsecutionCaseDefendantOffence.find_or_create_by!(
        prosecution_case_id: prosecution_case.id,
        defendant_id: model.subject_summary.subject_id,
        offence_id: offence.offence_id,
        application_type: model.application_type,
      )
    end

    prosecution_case
  end

private

  attr_reader :prosecution_case, :model
end
