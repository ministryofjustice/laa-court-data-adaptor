# frozen_string_literal: true

module CommonPlatform
  module Api
    class RecordProsecutionCaseRepresentationOrder < ApplicationService
      def initialize(case_defendant_offence:,
                     defendant_id:,
                     offence_id:,
                     status_code:,
                     application_reference:,
                     status_date:,
                     effective_start_date:,
                     defence_organisation:,
                     effective_end_date: nil,
                     connection: CommonPlatform::Connection.instance.call)
        @case_defendant_offence = case_defendant_offence
        @offence_id = offence_id
        @status_code = status_code
        @application_reference = application_reference.to_s
        @status_date = status_date
        @effective_start_date = effective_start_date
        @effective_end_date = effective_end_date
        @defence_organisation = defence_organisation
        @url = "prosecutionCases/representationOrder"\
                "/cases/#{case_defendant_offence.prosecution_case_id}"\
                "/defendants/#{defendant_id}"\
                "/offences/#{offence_id}"
        @connection = connection
      end

      def call
        response = connection.post(url, request_body)
        update_offence(response)
        response
      end

    private

      def request_body
        {
          statusCode: status_code,
          applicationReference: application_reference,
          statusDate: status_date,
          effectiveStartDate: effective_start_date,
          effectiveEndDate: effective_end_date,
          defenceOrganisation: defence_organisation,
        }.compact
      end

      def update_offence(response)
        case_defendant_offence.update!(
          rep_order_status: status_code,
          status_date:,
          effective_start_date:,
          effective_end_date:,
          defence_organisation:,
          response_status: response.status,
          response_body: response.body,
        )
      end

      attr_reader :url, :case_defendant_offence, :offence_id, :status_code, :application_reference, :status_date, :effective_start_date, :effective_end_date, :defence_organisation, :connection
    end
  end
end
