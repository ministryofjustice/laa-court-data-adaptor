# frozen_string_literal: true

module CommonPlatform
  module Api
    class GetCourtApplication < ApplicationService
      URL = "applicationID"

      def initialize(court_application_id: nil,
                     connection: CommonPlatform::Connection.call)
        @connection = connection
      end

      def call
        connection.get("URL/#{court_application_id}")
      end

    private
      attr_reader :connection
    end
  end
end
