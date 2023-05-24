# frozen_string_literal: true

module CommonPlatform
  module Api
    class SearchProsecutionCase < ApplicationService
      include ActionView::Helpers::SanitizeHelper

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
          message = "Common Platform API status: #{response.status}, body: #{sanitized_response}"

          raise CommonPlatform::Api::Errors::FailedDependency, message
        end
      end

      # In case of error, Common Platform API returns an HTML.
      # This sanitizes the error message to log, to reduce HTML tag noise
      def sanitized_response
        strip_tags(response.body.to_s).strip
      end

      attr_reader :response
    end
  end
end
