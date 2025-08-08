class CourtApplication < ApplicationRecord
  validates :body, presence: true

  # These are the titles of the types of court applications that we primarily support
  # and will return inside a prosecution case payload. Other court application types
  # will still be returned when attached to specific hearings.
  SUPPORTED_COURT_APPLICATION_TITLES = [
    "Appeal against conviction and sentence by a Magistrates' Court to the Crown Court",
    "Appeal against conviction by a Magistrates' Court to the Crown Court",
    "Appeal against sentence by a Magistrates' Court to the Crown Court",
  ].freeze

  def hearing_summaries
    body["hearingSummary"]
  end
end
