# frozen_string_literal: true

module Api
  class RecordLaaReference < ApplicationService
    # rubocop:disable Metrics/ParameterLists
    def initialize(prosecution_case_id:,
                   defendant_id:,
                   offence_id:,
                   status_code:,
                   application_reference:,
                   status_date:,
                   shared_key: ENV['SHARED_SECRET_KEY_LAA_REFERENCE'],
                   connection: CommonPlatformConnection.call)

      @offence_id = offence_id
      @status_code = status_code
      @application_reference = application_reference
      @status_date = status_date
      @connection = connection
      @url = '/record/laareference/progression-command-api'\
              '/command/api/rest/progression/laaReference'\
              "/cases/#{prosecution_case_id}"\
              "/defendants/#{defendant_id}"\
              "/offences/#{offence_id}"

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
        statusDate: status_date
      }
    end

    def update_database(response)
      offence = ProsecutionCaseDefendantOffence.find_by(offence_id: offence_id)
      offence.maat_reference = application_reference
      offence.dummy_maat_reference = (application_reference.to_s[0] == 'A')
      offence.rep_order_status = status_code
      offence.response_status = response.status
      offence.response_body = response.body
      offence.save!
    end

    attr_reader :url, :status_code, :application_reference, :status_date, :connection, :headers, :offence_id
  end
end
