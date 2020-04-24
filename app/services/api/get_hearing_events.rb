# frozen_string_literal: true

module Api
  class GetHearingEvents < ApplicationService
    def initialize(hearing_id:)
      @hearing_id = hearing_id
      @response = HearingEventsFetcher.call(hearing_id: hearing_id)
    end

    def call
      HearingEventsRecorder.call(hearing_id: hearing_id, events: response.body) if successful_response?
    end

    private

    def successful_response?
      response.status == 200
    end

    attr_reader :hearing_id, :response
  end
end
