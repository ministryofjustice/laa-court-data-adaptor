# frozen_string_literal: true

class ProsecutionCase < ApplicationRecord
  validates :body, presence: true

  def defendants
    body['defendantSummary'].map { |defendant| Defendant.new(body: defendant) }
  end

  def defendant_ids
    defendants.map(&:id)
  end

  def prosecution_case_reference
    body['prosecutionCaseReference']
  end
end
