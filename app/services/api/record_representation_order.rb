# frozen_string_literal: true

module Api
  class RecordRepresentationOrder < ApplicationService
    # rubocop:disable Metrics/ParameterLists
    def initialize(prosecution_case_id:,
                   defendant_id:,
                   offence_id:,
                   status_code:,
                   application_reference:,
                   status_date:,
                   effective_start_date:,
                   effective_end_date: nil,
                   defence_organisation:,
                   shared_key: ENV['SHARED_SECRET_KEY_REPRESENTATION_ORDER'],
                   connection: CommonPlatformConnection.call)

      @status_code = status_code
      @application_reference = application_reference
      @status_date = status_date
      @effective_start_date = effective_start_date
      @effective_end_date = effective_end_date
      @defence_organisation = defence_organisation
      @url = '/receive/representation/progression-command-api'\
              '/command/api/rest/progression/representationOrder' \
              "/cases/#{prosecution_case_id}" \
              "/defendants/#{defendant_id}" \
              "/offences/#{offence_id}"

      @connection = connection
      @headers = { 'Ocp-Apim-Subscription-Key' => shared_key }
    end
    # rubocop:enable Metrics/ParameterLists

    def call
      connection.post(url, request_body, headers)
    end

    private

    def request_body
      {
        statusCode: status_code,
        applicationReference: application_reference,
        statusDate: status_date,
        effectiveStartDate: effective_start_date,
        effectiveEndDate: effective_end_date,
        defenceOrganisation: defence_organisation
      }.compact
    end

    attr_reader :url, :status_code, :application_reference, :status_date, :effective_start_date, :effective_end_date, :defence_organisation, :headers, :connection
  end
end
