# frozen_string_literal: true

module CommonPlatform
  module Api
    class DefendantFinder < ApplicationService
      def initialize(defendant_id:)
        @defendant_id = defendant_id
        @prosecution_case_defendant = ProsecutionCaseDefendantOffence.find_by(defendant_id: defendant_id)
      end

      def call
        common_platform_defendant
      end

    private

      def common_platform_defendant
        @common_platform_defendant ||= common_platform_prosecution_case&.defendants&.find { |d| d.id.eql?(defendant_id) }
      end

      def common_platform_prosecution_case
        return unless prosecution_case_urn

        # fetch details needed to include plea and mode of trial reason, at least
        @common_platform_prosecution_case ||= CommonPlatform::Api::SearchProsecutionCase
                                              .call(prosecution_case_reference: prosecution_case_urn)
                                              &.first
                                              &.tap(&:fetch_details)
      end

      def prosecution_case_urn
        @prosecution_case_urn ||= prosecution_case&.body&.fetch("prosecutionCaseReference", nil)
      end

      def prosecution_case
        return unless prosecution_case_defendant

        @prosecution_case ||= prosecution_case_defendant.prosecution_case
      end

      attr_reader :defendant_id, :prosecution_case_defendant
    end
  end
end
