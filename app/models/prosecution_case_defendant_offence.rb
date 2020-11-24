# frozen_string_literal: true

class ProsecutionCaseDefendantOffence < ApplicationRecord
  validates :prosecution_case_id, presence: true
  validates :defendant_id, presence: true
  validates :offence_id, presence: true
  belongs_to :prosecution_case
end
