class CourtApplication < ApplicationRecord
  validates :body, presence: true

  def hearing_summaries
    body["hearingSummary"]
  end
end
