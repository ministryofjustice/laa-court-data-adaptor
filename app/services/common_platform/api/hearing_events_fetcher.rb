# frozen_string_literal: true

module CommonPlatform
  module Api
    class HearingEventsFetcher < ApplicationService
      URL = "hearing/hearingLog"

      def initialize(hearing_id:, hearing_date:, connection: CommonPlatform::Connection.instance.call)
        @params = { hearingId: hearing_id, date: hearing_date }
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
