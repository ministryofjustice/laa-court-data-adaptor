# frozen_string_literal: true

class ProsecutionCase < ApplicationRecord
  validates :body, presence: true

  def defendants
    body['defendantSummary'].map { |defendant| Defendant.new(body: defendant) }
  end

  def defendant_ids
    defendants.map(&:id)
  end

  def hearing_summaries
    body['hearingSummary'].map { |hearing_summary| HearingSummary.new(body: hearing_summary) }
  end

  def hearing_summary_ids
    hearing_summaries.map(&:id)
  end

  def prosecution_case_reference
    body['prosecutionCaseReference']
  end
end
