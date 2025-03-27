module CommonPlatform
  module Api
    class CourtApplicationSearcher < ApplicationService
      URL = "applications".freeze

      def initialize(application_id:,
                     connection: CommonPlatform::Connection.instance.call)
        @connection = connection
        @application_id = application_id
      end

      def call
        connection.get("#{URL}/#{application_id}")
      end

    private

      attr_reader :connection,
                  :application_id
    end
  end
end
