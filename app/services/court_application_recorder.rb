# frozen_string_literal: true

class CourtApplicationRecorder < ApplicationService
  def initialize(court_application_id, model)
    @court_application = CourtApplication.find_or_initialize_by(id: court_application_id)
    @model = model
  end

  def call
    court_application.update!(body: model.data)

    model.subject_summary.offence_summary.each do |offence|
      CourtApplicationDefendantOffence.find_or_create_by!(
        court_application_id: court_application.id,
        defendant_id: model.subject_summary.subject_id,
        offence_id: offence.offence_id,
        application_type: model.application_type,
      )
    end

    court_application
  end

private

  attr_reader :court_application, :model
end
