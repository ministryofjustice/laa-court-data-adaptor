# frozen_string_literal: true

module CommonPlatform
  module Api
    class HearingFetcher < ApplicationService
      URL = "hearing/results"

      def initialize(hearing_id:, hearing_day:, connection: CommonPlatform::Connection.call)
        @params = { hearingId: hearing_id, sittingDay: hearing_day }.compact
        @connection = connection
      end

      def call
        connection.get(URL, params)
      end

    private

      attr_reader :params, :connection
    end
  end
end
