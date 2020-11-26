# frozen_string_literal: true

module Api
  class SearchProsecutionCase < ApplicationService
    def initialize(params)
      @response = ProsecutionCaseSearcher.call(params)
    end

    def call
      record_search_results if successful_response?
    end

  private

    def successful_response?
      response.status == 200 && response.body["totalResults"].positive?
    end

    def record_search_results
      response.body["cases"].map do |prosecution_case|
        ProsecutionCaseRecorder.call(
          prosecution_case_id: prosecution_case["prosecutionCaseId"],
          body: prosecution_case,
        )
      end
    end

    attr_reader :response
  end
end
