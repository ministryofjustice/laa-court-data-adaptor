# frozen_string_literal: true

module CommonPlatform
  module Api
    class RecordCourtApplicationRepresentationOrder < ApplicationService
      def initialize(court_application_id:,
                     subject_id:,
                     offence_id:,
                     status_code:,
                     application_reference:,
                     status_date:,
                     effective_start_date:,
                     defence_organisation:,
                     effective_end_date: nil,
                     connection: CommonPlatform::Connection.instance.call)
        @status_code = status_code
        @application_reference = application_reference.to_s
        @status_date = status_date
        @effective_start_date = effective_start_date
        @effective_end_date = effective_end_date
        @defence_organisation = defence_organisation
        @url = "prosecutionCases/representationOrder"\
                "/applications/#{court_application_id}"\
                "/subject/#{subject_id}"\
                "/offences/#{offence_id}"
        @connection = connection
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
          effectiveStartDate: effective_start_date,
          effectiveEndDate: effective_end_date,
          defenceOrganisation: defence_organisation,
        }.compact
      end

      attr_reader :url, :status_code, :application_reference, :status_date, :effective_start_date, :effective_end_date, :defence_organisation, :connection
    end
  end
end
