class CourtApplication < ApplicationRecord
  validates :body, presence: true

  # TODO: When Appeals V2 is switched on we can remove this as we will remove the logic that relies on them
  SUPPORTED_COURT_APPLICATION_TITLES = [
    "Appeal against conviction and sentence by a Magistrates' Court to the Crown Court",
    "Appeal against conviction by a Magistrates' Court to the Crown Court",
    "Appeal against sentence by a Magistrates' Court to the Crown Court",
  ].freeze

  def self.supported_court_application_types
    @supported_court_application_types ||= YAML.load_file Rails.root.join("lib/supported_court_application_types.yaml")
  end

  def hearing_summaries
    body["hearingSummary"]
  end
end
