# frozen_string_literal: true

module CommonPlatform
  module Api
    class HearingFetcher < ApplicationService
      URL = "hearing/results"

      def initialize(hearing_id:, sitting_day:, connection: CommonPlatform::Connection.instance.call)
        @params = { hearingId: hearing_id, sittingDay: sitting_day }.reject { |_k, v| v.blank? }
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
