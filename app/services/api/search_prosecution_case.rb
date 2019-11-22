# frozen_string_literal: true

module Api
  class SearchProsecutionCase < ApplicationService
    include CommonPlatformConnection

    def initialize(prosecution_case_reference: nil, national_insurance_number: nil, arrest_summons_number: nil)
      @url = '/prosecutionCases'
      @prosecution_case_reference = prosecution_case_reference
      @national_insurance_number = national_insurance_number
      @arrest_summons_number = arrest_summons_number
    end

    def call
      @response ||= prosecution_case_search_request
      return unless successful_response?

      record_search_results
    end

    private

    def prosecution_case_search_request
      common_platform_connection.get(
        url,
        request_params
      )
    end

    def request_params
      return { prosecutionCaseReference: prosecution_case_reference } if prosecution_case_reference.present?
      return { arrestSummonsNumber: arrest_summons_number } if arrest_summons_number.present?

      { nationalInsuranceNumber: national_insurance_number }
    end

    def successful_response?
      response.status == 200 && response.body.present?
    end

    def record_search_results
      response.body['prosecutionCases'].each do |prosecution_case|
        ProsecutionCaseRecorder.call(
          prosecution_case['prosecutionCaseId'],
          prosecution_case
        )
      end
    end

    attr_reader :prosecution_case_reference, :national_insurance_number, :response, :url, :arrest_summons_number
  end
end
