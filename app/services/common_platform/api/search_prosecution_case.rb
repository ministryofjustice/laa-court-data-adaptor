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
        check_for_blank_defendants(prosecution_cases)
        record_prosecution_cases
      end

      def check_for_blank_defendants(prosecution_cases)
        if !prosecution_cases.nil? && !prosecution_cases.empty?
          prosecution_cases.each do |prosecution_case|
            if !prosecution_case["defendantSummary"].nil? && !prosecution_case["defendantSummary"].empty?
              prosecution_case["defendantSummary"].each do |defendant|
                # If the defendant is missing these values in their summary
                if (!defendant["defendantFirstName"]) && (!defendant["defendantLastName"]) && (!defendant["defendantDOB"]) && (!defendant["defendantNINO"])
                  if @empty_defendants.nil?
                    @empty_defendants = []
                  end
                  # Add this defendant to an array of empty defendants (we need to also verify they don't have a hearing summary further down)
                  @empty_defendants.push(defendant["defendantId"])
                end
              end
            end

            # We need to check the hearing summaries for the blank defendants
            if !prosecution_case["hearingSummary"].nil? && !prosecution_case["hearingSummary"].empty?
              prosecution_case["hearingSummary"].each do |hearing_summary|
                hearing_summary["defendantIds"].each do |defendant_id|
                  # If this defendant_id matches one of the empty defendants already found
                  if @empty_defendants.try(:include?, defendant_id)
                    # Remove them from the empty defendants array
                    @empty_defendants.delete(defendant_id)
                  end
                end
              end
            end

            # If there are empty defendants (missing names, DOB etc and have no hearing summaries)
            if !@empty_defendants.nil? && !@empty_defendants.empty?
              @empty_defendants.each do |empty_defendant|
                Rails.logger.error("The defendant with the defendantId [" + empty_defendant + "] is blank (missing defendantFirstName, defendantLastName, defendantDOB, defendantNINO and hearingSummary)")
                # Send an alert to sentry
                Sentry.capture_message("The defendant with the defendantId [" + empty_defendant + "] is blank (missing defendantFirstName, defendantLastName, defendantDOB, defendantNINO and hearingSummary)")
              end
            end
          end
        end
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
