# frozen_string_literal: true

module Api
  class GetHearingResults < ApplicationService
    def initialize(hearing_id:)
      @hearing_id = hearing_id
      @response = HearingFetcher.call(hearing_id: hearing_id)
    end

    def call
      HearingRecorder.call(hearing_id: hearing_id, body: response.body) if successful_response?
    end

    private

    def successful_response?
      response.status == 200
    end

    attr_reader :hearing_id, :response
  end
end
