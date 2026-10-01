# frozen_string_literal: true

module CommonPlatform
  module Api
    class RecordProsecutionCaseLaaReference < ApplicationService
      def initialize(case_defendant_offence:,
                     defendant_id:,
                     offence_id:,
                     status_code:,
                     application_reference:,
                     status_date:,
                     connection: CommonPlatform::Connection.instance.call)
        @case_defendant_offence = case_defendant_offence
        @status_code = status_code
        @application_reference = application_reference.to_s
        @status_date = status_date
        @connection = connection
        @url = "prosecutionCases/laaReference"\
                "/cases/#{case_defendant_offence.prosecution_case_id}"\
                "/defendant/#{defendant_id}"\
                "/offences/#{offence_id}"
      end

      def call
        response = connection.post(url, request_body)
        update_database(response)
        response
      end

    private

      def request_body
        {
          statusCode: status_code,
          applicationReference: application_reference,
          statusDate: status_date,
        }
      end

      def update_database(response)
        case_defendant_offence.update!(
          rep_order_status: status_code,
          status_date:,
          response_status: response.status,
          response_body: response.body,
        )
      end

      attr_reader :url, :case_defendant_offence, :status_code, :application_reference, :status_date, :connection
    end
  end
end
