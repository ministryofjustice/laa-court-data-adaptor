# frozen_string_literal: true

class ProsecutionCase < ApplicationRecord
  has_many :prosecution_case_defendant_offences
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

  def hearing_ids
    hearings.map(&:id)
  end

  def prosecution_case_reference
    body["prosecutionCaseReference"]
  end

  def load_hearing_results(defendant_id, load_events: true)
    hearing_results(defendant_id, load_events:)
  end

  def court_applications
    body["applicationSummary"].map { retrieve_full_court_application(it) }
                              .select(&:supported?)
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

  def hearing_results(defendant_id = nil, load_events: true)
    @hearing_results ||= hearing_summaries_for(defendant_id).flat_map { |hearing_summary|
      HearingResult.new(
        CommonPlatform::Api::GetHearingResults.call(
          hearing_id: hearing_summary.id,
        ),
        load_events:,
      )
    }.reject(&:blank?)
  end

  def hearing_summaries_for(defendant_id)
    hearing_summaries.select { |summary| defendant_id.nil? || summary.defendant_ids.include?(defendant_id) }
  end

  def retrieve_full_court_application(application_summary)
    response = CommonPlatform::Api::CourtApplicationSearcher.call(
      application_id: application_summary["applicationId"],
    )

    raise CommonPlatform::Api::Errors::FailedDependency, "Error retrieving court application" unless response.success?

    HmctsCommonPlatform::CourtApplicationSummary.new(response.body)
  end
end
