# frozen_string_literal: true

module CommonPlatform
  module Api
    class SearchProsecutionCase < ApplicationService
      include ActionView::Helpers::SanitizeHelper

      def initialize(params)
        @response = ProsecutionCaseSearcher.call(**params)
        @blank_defendants = []
      end

      def call
        check_response_status
        check_for_blank_defendants(prosecution_cases)
        record_prosecution_cases
      end

      def check_for_blank_defendants(prosecution_cases)
        if array_not_empty(prosecution_cases)
          prosecution_cases.each do |prosecution_case|
            if array_not_empty(prosecution_case["defendantSummary"])
              prosecution_case["defendantSummary"].each do |defendant|
                if defendant_is_blank(defendant)
                  # Add this defendant to an array of empty defendants (we need to also verify they don't have a hearing summary further down)
                  @blank_defendants.push(defendant["defendantId"])
                end
              end
            end

            remove_defendant_with_hearing_summary_from_blank_defendants(prosecution_case["hearingSummary"])
            log_error_for_blank_defendants
          end
        end
      end

      def remove_defendant_with_hearing_summary_from_blank_defendants(hearing_summaries)
        if array_not_empty(hearing_summaries)
          hearing_summaries.each do |hearing_summary|
            hearing_summary["defendantIds"].each do |defendant_id|
              # If this defendant_id matches one of the blank defendants already found
              if @blank_defendants.try(:include?, defendant_id)
                # Remove them from the blank defendants array
                @blank_defendants.delete(defendant_id)
              end
            end
          end
        end
      end

      def log_error_for_blank_defendants
        if array_not_empty(@blank_defendants)
          @blank_defendants.each do |blank_defendant|
            Rails.logger.error("The defendant with the defendantId [#{blank_defendant}] is blank (missing defendantFirstName, defendantLastName, defendantDOB, defendantNINO and hearingSummary)")
            # Send an alert to sentry
            Sentry.capture_message("The defendant with the defendantId [#{blank_defendant}] is blank (missing defendantFirstName, defendantLastName, defendantDOB, defendantNINO and hearingSummary)")
          end
        end
      end

      def array_not_empty(array)
        array.present?
      end

      def defendant_is_blank(defendant)
        !defendant["defendantFirstName"] && !defendant["defendantLastName"] && !defendant["defendantDOB"] && !defendant["defendantNINO"]
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
