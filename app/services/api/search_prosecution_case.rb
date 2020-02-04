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
      response.status == 200 && response.body.present?
    end

    def record_search_results
      response.body.map do |prosecution_case|
        ProsecutionCaseRecorder.call(
          prosecution_case['prosecutionCaseId'],
          prosecution_case
        )
      end
    end

    attr_reader :response
  end
end
