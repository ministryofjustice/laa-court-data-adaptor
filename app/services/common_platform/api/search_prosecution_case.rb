# frozen_string_literal: true

module CommonPlatform
  module Api
    class SearchProsecutionCase < ApplicationService
      include ActionView::Helpers::SanitizeHelper

      def initialize(params)
        @response = ProsecutionCaseFetcher.call(**params)
        @blank_defendants = []
      end

      def call
        check_response_status
        check_for_blank_defendants(prosecution_cases)
        record_prosecution_cases
      end

      def check_for_blank_defendants(prosecution_cases)
        return if prosecution_cases.nil?

        prosecution_cases.each do |prosecution_case|
          prosecution_case["defendantSummary"]&.map! do |defendant| # Use `map!` to update the array in place
            if defendant_is_blank(defendant)
              # Add this defendant to an array of empty defendants (we need to also verify they don't have a hearing summary further down)
              @blank_defendants.push(defendant["defendantId"])
            else
              # Initialize `applicationSummary` as an array if not already present
              defendant["applicationSummary"] ||= []
              # Match and update `applicationSummary` directly
              match_application_summaries(defendant, prosecution_case["applicationSummary"]) if prosecution_case["applicationSummary"].present? && prosecution_case["applicationSummary"].any?
            end
            defendant # Return the updated defendant
          end

          remove_defendant_with_hearing_summary_from_blank_defendants(prosecution_case["hearingSummary"])
          log_error_for_blank_defendants
        end
      end

      def remove_defendant_with_hearing_summary_from_blank_defendants(hearing_summaries)
        return if hearing_summaries.nil?

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

      def log_error_for_blank_defendants
        @blank_defendants.each do |blank_defendant|
          Rails.logger.error("The defendant with the defendantId [#{blank_defendant}] is blank (missing defendantFirstName, defendantLastName, defendantDOB, defendantNINO and hearingSummary)")
          # Send an alert to sentry
          Sentry.capture_message("The defendant with the defendantId [#{blank_defendant}] is blank (missing defendantFirstName, defendantLastName, defendantDOB, defendantNINO and hearingSummary)")
        end
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

      def match_application_summaries(defendant, application_summaries)
        return [] if application_summaries.nil? # Return an empty array if no application summaries are provided

        matched_summaries = [] # Initialize an array to store matched application summaries

        application_summaries.each do |application_summary|
          next unless application_summary.dig("subjectSummary", "defendantFirstName").to_s.strip == defendant["defendantFirstName"].to_s.strip &&
            application_summary.dig("subjectSummary", "defendantLastName").to_s.strip == defendant["defendantLastName"].to_s.strip

          matched_summaries << application_summary # Add the matched summary to the array
        end

        # Assign matched summaries to defendant["applicationSummaries"] if any matches are found
        defendant["applicationSummaries"] ||= [] # Initialize as an array if not already present
        defendant["applicationSummaries"].concat(matched_summaries) # Add matched summaries to the defendant's applicationSummaries

        matched_summaries
      end

      attr_reader :response
    end
  end
end
