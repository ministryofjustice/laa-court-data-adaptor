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

      @offence_id = offence_id
      @status_code = status_code
      @application_reference = application_reference
      @status_date = status_date
      @effective_start_date = effective_start_date
      @effective_end_date = effective_end_date
      @defence_organisation = defence_organisation
      @url = '/progression-command-api'\
              '/command/api/rest/progression/representationOrder' \
              "/cases/#{prosecution_case_id}" \
              "/defendants/#{defendant_id}" \
              "/offences/#{offence_id}"

      @connection = connection
      @headers = { 'Ocp-Apim-Subscription-Key' => shared_key }
    end
    # rubocop:enable Metrics/ParameterLists

    def call
      response = connection.post(url, request_body, headers)
      update_database(response)
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
        defenceOrganisation: defence_organisation
      }.compact
    end

    def update_database(response)
      offence = ProsecutionCaseDefendantOffence.find_by(offence_id: offence_id)
      offence.rep_order_status = status_code
      offence.status_date = status_date
      offence.effective_start_date = effective_start_date
      offence.effective_end_date = effective_end_date
      offence.defence_organisation = defence_organisation
      offence.response_status = response.status
      offence.response_body = response.body
      offence.save!
    end

    attr_reader :url, :offence_id, :status_code, :application_reference, :status_date, :effective_start_date, :effective_end_date, :defence_organisation, :headers, :connection
  end
end
