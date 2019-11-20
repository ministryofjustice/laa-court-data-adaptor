# frozen_string_literal: true

module Api
  class SearchProsecutionCase < ApplicationService
    include CommonPlatformConnection

    def initialize(prosecution_case_reference)
      @url = '/prosecutionCases'
      @prosecution_case_reference = prosecution_case_reference
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
        prosecutionCaseReference: prosecution_case_reference
      )
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

    attr_reader :prosecution_case_reference, :response, :url
  end
end
