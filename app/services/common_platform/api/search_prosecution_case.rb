# frozen_string_literal: true

module CommonPlatform
  module Api
    class SearchProsecutionCase < ApplicationService
      def initialize(params)
        @response = ProsecutionCaseSearcher.call(**params)
      end

      def call
        check_response_status

        record_prosecution_cases
      end

    private

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

      def check_response_status
        if response.status != 200
          message = "body: #{response.body}, status: #{response.status}"

          raise CommonPlatform::Api::Errors::FailedDependency, message
        end
      end

      attr_reader :response
    end
  end
end
