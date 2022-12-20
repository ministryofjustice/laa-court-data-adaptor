# frozen_string_literal: true

module CommonPlatform
  module Api
    class GetHearingEvents < ApplicationService
      def initialize(hearing_id:, hearing_date:)
        @hearing_id = hearing_id
        @hearing_date = hearing_date
        @response = HearingEventsFetcher.call(hearing_id: hearing_id, hearing_date: hearing_date)
      end

      def call
        if successful_response?
          HearingEventRecording.new(
            hearing_id: hearing_id,
            hearing_date: hearing_date,
            body: response.body,
          )
        end
      end

    private

      def successful_response?
        response.status == 200 && response.body.present?
      end

      attr_reader :hearing_id, :hearing_date, :response
    end
  end
end
