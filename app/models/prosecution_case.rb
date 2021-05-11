# frozen_string_literal: true

class ProsecutionCase < ApplicationRecord
  validates :body, presence: true

  def defendants
    body["defendantSummary"].map do |defendant|
      Defendant.new(
        body: defendant,
        details: defendant_details[defendant["defendantId"]],
        prosecution_case_id: id,
      )
    end
  end

  def defendant_ids
    defendants.map(&:id)
  end

  def hearing_summaries
    Array(body["hearingSummary"]).map do |hearing_summary|
      HearingSummary.new(body: hearing_summary)
    end
  end

  def hearing_summary_ids
    hearing_summaries.map(&:id)
  end

  def hearings
    hearing_results.select(&:body)
  end
  alias_method :fetch_details, :hearings

  def hearing_ids
    hearings.map(&:id)
  end

  def prosecution_case_reference
    body["prosecutionCaseReference"]
  end

private

  def case_details
    hearings.flat_map { |hearing|
      hearing.body.dig("hearing", "prosecutionCases")&.select { |prosecution_case| prosecution_case["id"] == id }
    }.compact
  end

  def hearings_fetched?
    @hearing_results.present?
  end

  def defendant_details
    return {} unless hearings_fetched?

    case_details.flat_map { |detail| detail["defendants"] }.group_by { |detail| detail["id"] }
  end

  def hearing_results
    @hearing_results ||= hearing_summaries.flat_map { |hearing_summary|
      hearing_summary.hearing_days.map do |hearing_day|
        CommonPlatform::Api::GetHearingResults.call(
          hearing_id: hearing_summary.id,
          hearing_day: hearing_day,
        )
      end
    }.compact
  end
end
