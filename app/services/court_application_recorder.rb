# frozen_string_literal: true

class CourtApplicationRecorder < ApplicationService
  def initialize(court_application_id, model)
    @court_application = CourtApplication.find_or_initialize_by(id: court_application_id)
    @model = model
  end

  def call
    court_application.update!(body: model.data)

    # A lock on the application helps avoid 2 simultaneous processes creating duplicate records
    court_application.with_lock { create_offence_records }

    court_application
  end

private

  attr_reader :court_application, :model

  def create_offence_records
    # Pull all existing records out of the DB in a single query here and
    # retain them in memory as an array. That way, in the most common case,
    # where the records already exist, no further DB interactions are needed,
    # so we avoid an N+1 query issue.
    local_records = court_application.court_application_defendant_offences
                                     .where(application_type: model.application_type,
                                            defendant_id: model.subject_summary.subject_id)
                                     .to_a

    model.subject_summary.offence_summary.each do |offence|
      next if local_records.any? { |record| record.offence_id == offence.offence_id }

      CourtApplicationDefendantOffence.create!(
        court_application_id: court_application.id,
        defendant_id: model.subject_summary.subject_id,
        offence_id: offence.offence_id,
        application_type: model.application_type,
      )
    end
  end
end
