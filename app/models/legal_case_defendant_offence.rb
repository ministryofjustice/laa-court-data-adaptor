class LegalCaseDefendantOffence < ApplicationRecord
  # Note that despite the table name, these records can link either
  # prosecution cases OR court applications
  self.table_name = "prosecution_case_defendant_offences"

  alias_attribute :court_application_id, :prosecution_case_id

  validates :defendant_id, presence: true
  validates :offence_id, presence: true
end
