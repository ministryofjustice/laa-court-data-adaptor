# frozen_string_literal: true

class ProsecutionCaseDefendantOffence < LegalCaseDefendantOffence
  validates :prosecution_case_id, presence: true
  belongs_to :prosecution_case

  # Application types are only relevant to court applications,
  # so we can use their presence to weed out court applications
  default_scope { where(application_type: nil) }
end
