# frozen_string_literal: true

class ProsecutionCase < ApplicationRecord
  validates :body, presence: true

  def defendants
    body['defendants'].map { |defendant| Defendant.new(body: defendant) }
  end

  def defendant_ids
    defendants.map(&:id)
  end

  def hearing_summaries
    body['hearings'].map { |hearing_summary| HearingSummary.new(body: hearing_summary) }
  end

  def hearing_summary_ids
    hearing_summaries.map(&:id) if body['hearings'].present?
  end

  def prosecution_case_reference
    body['prosecutionCaseReference']
  end
end
