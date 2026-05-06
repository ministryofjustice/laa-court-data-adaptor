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

  # Civil case proceedings (e.g. ASB injunctions, stalking protection orders) produce a nil
  # category for now, as they are not yet mapped in supported_court_application_types.yaml.
  def supported_category?
    SupportedCourtApplicationTypes.get_category_by_code(body["applicationType"]).present?
  end
end
