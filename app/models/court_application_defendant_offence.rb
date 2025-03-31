class CourtApplicationDefendantOffence < LegalCaseDefendantOffence
  alias_attribute :court_application_id, :prosecution_case_id
  validates :court_application_id, presence: true
  belongs_to :court_application

  # Application types are only relevant to court applications,
  # so we can use their presence to weed out court applications
  default_scope { where.not(application_type: nil) }
end
