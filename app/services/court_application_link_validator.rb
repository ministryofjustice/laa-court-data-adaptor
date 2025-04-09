class CourtApplicationLinkValidator < ApplicationService
  def initialize(subject_id:)
    @court_application = CourtApplicationDefendantOffence.find_by(defendant_id: subject_id)&.court_application
  end

  def call
    (court_application&.hearing_summaries || []).any?
  end

private

  attr_reader :court_application
end
