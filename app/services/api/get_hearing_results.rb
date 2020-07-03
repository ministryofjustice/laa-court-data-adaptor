# frozen_string_literal: true

module Api
  class GetHearingResults < ApplicationService
    def initialize(hearing_id:, publish_to_queue: false)
      @hearing_id = hearing_id
      @publish_to_queue = publish_to_queue
      @response = HearingFetcher.call(hearing_id: hearing_id)
    end

    def call
      HearingRecorder.call(hearing_id: hearing_id, body: response.body, publish_to_queue: publish_to_queue) if successful_response?
    end

    private

    def successful_response?
      response.status == 200 && response.body.present?
    end

    attr_reader :hearing_id, :response, :publish_to_queue
  end
end
