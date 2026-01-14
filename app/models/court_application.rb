class CourtApplication < ApplicationRecord
  validates :body, presence: true

  def self.supported_court_application_types
    @supported_court_application_types ||= YAML.load_file Rails.root.join("lib/supported_court_application_types.yaml")
  end

  def hearing_summaries
    body["hearingSummary"]
  end

  def appeal?
    application_type = body["applicationType"]
    category = SupportedCourtApplicationTypes.get_category_by_code(application_type)

    category == "appeal"
  end
end
