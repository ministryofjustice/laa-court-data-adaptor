# frozen_string_literal: true

module Api
  class SearchProsecutionCase < ApplicationService
    def initialize(prosecution_case_reference)
      @prosecution_case_reference = prosecution_case_reference
    end

    def call
      @response ||= ProsecutionCaseSearcher.call(prosecution_case_reference)
      return unless successful_response?

      record_search_results
    end

    private

    def successful_response?
      response.status == 200
    end

    def record_search_results
      JSON.parse(response.body)['prosecutionCases'].each do |prosecution_case|
        ProsecutionCaseRecorder.call(
          prosecution_case['prosecutionCaseId'],
          prosecution_case
        )
      end
    end

    attr_reader :prosecution_case_reference, :response
  end
end
