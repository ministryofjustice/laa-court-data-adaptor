# frozen_string_literal: true

module Api
  class SearchProsecutionCase < ApplicationService
    include CommonPlatformConnection

    # rubocop:disable Metrics/ParameterLists
    def initialize(prosecution_case_reference: nil,
                   national_insurance_number: nil,
                   arrest_summons_number: nil,
                   name: nil,
                   date_of_birth: nil,
                   date_of_next_hearing: nil,
                   shared_key: ENV['SHARED_SECRET_KEY_SEARCH_PROSECUTION_CASE'])
      @url = '/search/case-sit/prosecutionCases'
      @prosecution_case_reference = prosecution_case_reference
      @national_insurance_number = national_insurance_number
      @arrest_summons_number = arrest_summons_number
      @name = name
      @date_of_birth = date_of_birth
      @date_of_next_hearing = date_of_next_hearing
      @headers = { 'LAASearchCase-Subscription-Key' => shared_key }
    end
    # rubocop:enable Metrics/ParameterLists

    def call
      @response ||= prosecution_case_search_request
      return unless successful_response?

      record_search_results
    end

    private

    def prosecution_case_search_request
      common_platform_connection.get(
        url,
        request_params,
        headers
      )
    end

    def request_params
      return { prosecutionCaseReference: prosecution_case_reference } if prosecution_case_reference.present?
      return { arrestSummonsNumber: arrest_summons_number } if arrest_summons_number.present?
      return { name: name, dateOfNextHearing: date_of_next_hearing } if date_of_next_hearing.present?
      return { name: name, dateOfBirth: date_of_birth } if date_of_birth.present?

      { nationalInsuranceNumber: national_insurance_number }
    end

    def successful_response?
      response.status == 200 && response.body.present?
    end

    def record_search_results
      response.body.each do |prosecution_case|
        ProsecutionCaseRecorder.call(
          prosecution_case['prosecutionCaseId'],
          prosecution_case
        )
      end
    end

    attr_reader :prosecution_case_reference, :national_insurance_number, :response, :url, :arrest_summons_number, :name, :date_of_birth, :date_of_next_hearing, :headers
  end
end
