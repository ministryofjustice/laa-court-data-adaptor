# frozen_string_literal: true

module CommonPlatform
  module Api
    class GetHearingResults < ApplicationService
      def initialize(hearing_id:, sitting_day: nil, publish_to_queue: false)
        @hearing_id = hearing_id
        @publish_to_queue = publish_to_queue
        @response = HearingFetcher.call(hearing_id: hearing_id, sitting_day: sitting_day)
      end

      def call
        if successful_response?
          publish_hearing_to_queue if publish_to_queue
          response.body
        end
      end

    private

      def successful_response?
        response.success? && response.body.present?
      end

      def publish_hearing_to_queue
        HearingsCreatorWorker.perform_async(
          Current.request_id,
          response.body.deep_stringify_keys,
        )
      end

      attr_reader :publish_to_queue, :response
    end
  end
end
