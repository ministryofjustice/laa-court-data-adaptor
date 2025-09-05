module CommonPlatform
  module Api
    class RecordCourtApplicationLaaReference < ApplicationService
      def initialize(application_id:,
                     subject_id:,
                     offence_id:,
                     status_code:,
                     application_reference:,
                     status_date:,
                     connection: CommonPlatform::Connection.instance.call)
        @offence_id = offence_id
        @status_code = status_code
        @application_reference = application_reference.to_s
        @status_date = status_date
        @connection = connection

        @url = if @offence_id
                 "prosecutionCases/laaReference"\
                 "/applications/#{application_id}"\
                 "/subject/#{subject_id}"\
                 "/offences/#{offence_id}"
               else
                 "prosecutionCases/laaReference"\
                 "/applications/#{application_id}"
               end
      end

      def call
        connection.post(url, request_body)
      end

    private

      def request_body
        {
          statusCode: status_code,
          applicationReference: application_reference,
          statusDate: status_date,
        }
      end

      attr_reader :url, :status_code, :application_reference, :status_date, :connection, :offence_id
    end
  end
end
