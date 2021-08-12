# frozen_string_literal: true

class ProsecutionCaseHearingsFetcher < ApplicationService
  def initialize(prosecution_case_id:)
    @prosecution_case = ProsecutionCase.find(prosecution_case_id)
  end

  def call
    hearings.map { |hearing| get_hearing_results(hearing) }
  end

private

  def get_hearing_results(hearing)
    CommonPlatformApi::GetHearingResults.call(
      hearing_id: hearing["hearingId"],
      publish_to_queue: true,
    )
  end

  def hearings
    prosecution_case.body["hearingSummary"] || []
  end

  attr_reader :prosecution_case
end
