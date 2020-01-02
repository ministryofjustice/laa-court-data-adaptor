# frozen_string_literal: true

module Api
  class RecordLaaReference < ApplicationService
    include CommonPlatformConnection

    attr_reader :url, :prosecution_case_id, :defendant_id,
                :offence_id, :status_code, :application_reference,
                :status_date, :common_platform_shared_secret_key

    # rubocop:disable Metrics/ParameterLists
    def initialize(laa_reference_id:, prosecution_case_id:, defendant_id:, offence_id:, status_code:, application_reference:, status_date:)
      @prosecution_case_id = prosecution_case_id
      @defendant_id = defendant_id
      @offence_id = offence_id
      @status_code = status_code
      @application_reference = application_reference
      @status_date = status_date
      @url = "/prosecutionCases/laaReference/#{laa_reference_id}"
      @common_platform_shared_secret_key = 'COMMON_PLATFORM_SHARED_SECRET_KEY'
    end
    # rubocop:enable Metrics/ParameterLists

    def call
      common_platform_connection.put(url, request_body)
    end

    private

    def request_body
      {
        prosecutionCaseId: prosecution_case_id,
        defendantId: defendant_id,
        offenceId: offence_id,
        statusCode: status_code,
        applicationReference: application_reference,
        statusDate: status_date
      }
    end
  end
end
