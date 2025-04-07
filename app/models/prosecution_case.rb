# frozen_string_literal: true

class ProsecutionCase < LegalCase
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

  def hearing_ids
    hearings.map(&:id)
  end

  def prosecution_case_reference
    body["prosecutionCaseReference"]
  end

  # In order to populate "details" for a defendant (see #defendants above)
  # we need to retrieve hearing results. If we retrieve all hearing results
  # relating to a particular defendant, we get a full list of things like
  # post_hearing_custody_statuses and judicial_results.
  # However, to retrieve things like mode of trial reasons we only need to retrieve a single
  # hearing result, as the details "offence" payload attached to it will give us the full
  # answer for mode of trial reasons. So this method retrieves hearing results for a given
  # defendant, and optionally stops are soon as it's retrieved a single populated one
  def load_hearing_results(defendant_id, load_all: true)
    relevant_summaries = hearing_summaries.select { |summary| summary.defendant_ids.include?(defendant_id) }
    candidate_lookups = relevant_summaries.flat_map do |hearing_summary|
      hearing_summary.hearing_days.map do |hearing_day|
        {
          hearing_id: hearing_summary.id,
          sitting_day: hearing_day.sitting_day,
        }
      end
    end

    loaded = []
    candidate_lookups.each do |params|
      result = HearingResult.new(
        CommonPlatform::Api::GetHearingResults.call(**params),
      )
      next if result.blank?

      loaded << result
      break unless load_all
    end

    @hearing_results = loaded
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
