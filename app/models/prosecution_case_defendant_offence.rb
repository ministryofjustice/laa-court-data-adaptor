# frozen_string_literal: true

class ProsecutionCaseDefendantOffence < LegalCaseDefendantOffence
  validates :prosecution_case_id, presence: true
  belongs_to :prosecution_case
end
