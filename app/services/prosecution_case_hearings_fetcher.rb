# frozen_string_literal: true

class ProsecutionCaseHearingsFetcher < ApplicationService
  def initialize(prosecution_case_id:)
    @prosecution_case = ProsecutionCase.find(prosecution_case_id)
  end

  def call
    prosecution_case.body['hearingSummary'].map { |hearing| Api::GetHearingResults.call(hearing_id: hearing['hearingId']) }
  end

  private

  attr_reader :prosecution_case
end
