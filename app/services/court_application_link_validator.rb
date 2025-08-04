class CourtApplicationLinkValidator < ApplicationService
  def initialize(subject_id:)
    @court_application = CourtApplication.find_by(subject_id:)
  end

  def call
    (court_application&.hearing_summaries || []).any?
  end

private

  attr_reader :court_application
end
