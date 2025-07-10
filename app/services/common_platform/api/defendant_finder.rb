# frozen_string_literal: true

module CommonPlatform
  module Api
    # Note that this service can be _slow_ because it loads all hearing results
    # related to a defendant in order to populate the plea history
    class DefendantFinder < ApplicationService
      def initialize(defendant_id:, urn: nil)
        @defendant_id = defendant_id
        @urn = urn
      end

      def call
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

    private

      def common_platform_prosecution_case(urn)
        return unless urn

        prosecution_case = ProsecutionCaseFinder.call(urn, defendant_id)

        # fetch details needed to include plea and mode of trial reason, at least
        prosecution_case&.load_hearing_results(defendant_id, load_events: false)

        prosecution_case
      end

      def prosecution_case_urns
        return [urn] if urn.present?
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

      attr_reader :defendant_id, :urn
    end
  end
end
