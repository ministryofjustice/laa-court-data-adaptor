# frozen_string_literal: true

module CommonPlatform
  module Api
    class DefendantFinder < ApplicationService
      def initialize(defendant_id:)
        @defendant_id = defendant_id
      end

      def call
        common_platform_defendant
      end

    private

      def common_platform_defendant
        return @common_platform_defendant if @common_platform_defendant
        return unless prosecution_case_urns

        prosecution_case_urns.each do |urn|
          prosecution_case = common_platform_prosecution_case(urn)

          next unless prosecution_case

          @common_platform_defendant ||= prosecution_case.defendants&.find { |d| d.id.eql?(defendant_id) }

          return @common_platform_defendant if @common_platform_defendant
        end

        nil
      end

      def common_platform_prosecution_case(urn)
        return unless urn

        # fetch details needed to include plea and mode of trial reason, at least
        prosecution_case = CommonPlatform::Api::SearchProsecutionCase.call(prosecution_case_reference: urn)&.first

        prosecution_case&.load_hearing_results(defendant_id)

        prosecution_case
      end

      def prosecution_case_urns
        return unless prosecution_cases

        @prosecution_case_urns ||= prosecution_cases.map { |p_case| p_case.body&.fetch("prosecutionCaseReference", nil) }
      end

      def prosecution_cases
        return unless defendant_id

        @prosecution_cases ||= begin
          prosecution_case_ids = ProsecutionCaseDefendantOffence.joins(:prosecution_case)
                                                                .where(defendant_id:)
                                                                .pluck(:prosecution_case_id)

          ProsecutionCase.where(id: prosecution_case_ids)
        end
      end

      attr_reader :defendant_id
    end
  end
end
