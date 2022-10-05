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
    Array(body["hearingSummary"]).map do |hearing_summary_data|
      HmctsCommonPlatform::HearingSummary.new(hearing_summary_data)
    end
  end

  def hearing_summary_ids
    hearing_summaries.map(&:id)
  end

  def hearings
    hearing_results.map(&:hearing)
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
      hearing.prosecution_cases.select { |prosecution_case| prosecution_case.id == id }
    }.compact
  end

  def hearings_fetched?
    @hearing_results.present?
  end

  def defendant_details
    return {} unless hearings_fetched?

    case_details
      .flat_map(&:defendants)
      .map(&:data)
      .group_by { |defendant| defendant["id"] }
  end

  def hearing_results
    @hearing_results ||= hearing_summaries.flat_map { |hearing_summary|
      hearing_summary.hearing_days.map do |hearing_day|
        HearingResult.new(
          CommonPlatform::Api::GetHearingResults.call(
            hearing_id: hearing_summary.id,
            sitting_day: hearing_day.sitting_day,
          ),
        )
      end
    }.reject(&:blank?)
  end
end
