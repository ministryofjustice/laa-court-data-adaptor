# frozen_string_literal: true

module CommonPlatform
  module Api
    class GetHearingResults < ApplicationService
      def initialize(hearing_id:, hearing_day: nil, publish_to_queue: false)
        @hearing_id = hearing_id
        @publish_to_queue = publish_to_queue
        @response = HearingFetcher.call(hearing_id: hearing_id, hearing_day: hearing_day)
      end

      def call
        if successful_response?
          HearingRecorder.call(
            hearing_id: hearing_id,
            hearing_resulted_data: response.body,
            publish_to_queue: publish_to_queue,
          )
        end
      end

    private

      def successful_response?
        response.status == 200 && response.body.present?
      end

      attr_reader :hearing_id, :response, :publish_to_queue
    end
  end
end
