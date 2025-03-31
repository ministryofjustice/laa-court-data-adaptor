class CourtApplicationDefendantOffence < LegalCaseDefendantOffence
  alias_attribute :court_application_id, :prosecution_case_id
  validates :court_application_id, presence: true
  belongs_to :court_application
end
