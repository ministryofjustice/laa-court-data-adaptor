# frozen_string_literal: true

class CourtApplicationRecorder < ApplicationService
  def initialize(court_application_id, model)
    @court_application_id = court_application_id
    @model = model
  end

  def call
    # Lock the whole table while we establish if we are creating or updating
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute("LOCK prosecution_cases IN ACCESS EXCLUSIVE MODE")
      @court_application = CourtApplication.find_or_initialize_by(id: court_application_id)
      warn_if_subject_id_already_recorded
      court_application.update!(body: model.data, subject_id:)
    end

    court_application
  end

private

  attr_reader :court_application, :court_application_id, :model

  def warn_if_subject_id_already_recorded
    return if subject_id.blank?

    other_ids = CourtApplication.where(subject_id:).where.not(id: court_application_id).pluck(:id)
    return if other_ids.empty?

    Sentry.capture_message(
      "#{self.class.name} - Subject ID #{subject_id} of court application #{court_application_id} is already recorded on court application(s) #{other_ids.join(', ')}",
      level: :warning,
    )
  end

  def subject_id
    model.subject_summary.subject_id
  end
end
