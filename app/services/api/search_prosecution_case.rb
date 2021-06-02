# frozen_string_literal: true

module Api
  class SearchProsecutionCase < ApplicationService
    def initialize(params)
      @response = ProsecutionCaseSearcher.call(params)
    end

    def call
      record_prosecution_cases if search_results?
    end

  private

    def search_results?
      if response.body.include?("<html>")
        Sentry.capture_message("Response body contains HTML")
      end

      response.status == 200 && response.body["totalResults"]&.positive?
    end

    def record_prosecution_cases
      prosecution_cases.map { |prosecution_case| record_prosecution_case(prosecution_case) }
    end

    def record_prosecution_case(prosecution_case)
      ProsecutionCaseRecorder.call(
        prosecution_case_id: prosecution_case["prosecutionCaseId"],
        body: prosecution_case,
      )
    end

    def prosecution_cases
      response.body["cases"]
    end

    attr_reader :response
  end
end
