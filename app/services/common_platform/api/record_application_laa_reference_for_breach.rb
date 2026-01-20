module CommonPlatform
  module Api
    class RecordApplicationLaaReferenceForBreach < ApplicationService
      def initialize(application_id:,
                     status_code:,
                     application_reference:,
                     status_date:,
                     connection: CommonPlatform::Connection.instance.call)
        @status_code = status_code
        @application_reference = application_reference.to_s
        @status_date = status_date
        @connection = connection

        @url = "prosecutionCases/laaReference/applications/#{application_id}"
      end

      def call
        request_body = {
          statusCode: @status_code,
          applicationReference: @application_reference,
          statusDate: @status_date,
        }

        @connection.post(@url, request_body)
      end
    end
  end
end
