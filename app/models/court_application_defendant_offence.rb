class CourtApplicationDefendantOffence < LegalCaseDefendantOffence
  belongs_to :court_application, foreign_key: :prosecution_case_id

  validates :court_application_id, presence: true
  validates :application_type, presence: true

  # Application types are only relevant to court applications,
  # so we can use their presence to weed out court applications
  default_scope { where.not(application_type: nil) }
end
