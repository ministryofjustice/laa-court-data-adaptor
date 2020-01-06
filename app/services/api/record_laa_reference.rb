# frozen_string_literal: true

module Api
  class RecordLaaReference < ApplicationService
    include CommonPlatformConnection

    # rubocop:disable Metrics/ParameterLists
    def initialize(prosecution_case_id:,
                   defendant_id:,
                   offence_id:,
                   status_code:,
                   application_reference:,
                   status_date:,
                   shared_key: ENV['SHARED_SECRET_KEY_LAA_REFERENCE'])

      @status_code = status_code
      @application_reference = application_reference
      @status_date = status_date
      @url = '/record/laareference-sit/progression-command-api'\
              '/command/api/rest/progression/laaReference'\
              "/cases/#{prosecution_case_id}"\
              "/defendants/#{defendant_id}"\
              "/offences/#{offence_id}"

      @headers = { 'LAAReference-Subscription-Key' => shared_key }
    end
    # rubocop:enable Metrics/ParameterLists

    def call
      common_platform_connection.post(url, request_body, headers)
    end

    private

    def request_body
      {
        statusCode: status_code,
        applicationReference: application_reference,
        statusDate: status_date
      }
    end

    attr_reader :url, :status_code, :application_reference, :status_date, :headers
  end
end
