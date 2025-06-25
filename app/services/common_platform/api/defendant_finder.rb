# frozen_string_literal: true

module CommonPlatform
  module Api
    class DefendantFinder < ApplicationService
      def initialize(defendant_id:)
        @defendant_id = defendant_id
      end

      def call
        common_platform_defendant || detect_spaces_error
        # There is a known Common Platform issue where it sometimes tells us
        # about records with spaces in them, but then when
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

        prosecution_case = load_from_common_platform(urn)

        # fetch details needed to include plea and mode of trial reason, at least
        prosecution_case&.load_hearing_results(defendant_id, load_events: false)

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

      def detect_spaces_error
        # There is a known Common Platform issue where it sometimes tells us
        # about records with spaces in their URNs, but then when we search specifically
        # for that URN it seems to strip out the space and then can't find the record
        # we asked for. If that particular thing is what happens and causes a defendant
        # not to be found, raise an error with a `spaces_in_urn` code so that VCD can
        # inform the user of something specific.
        with_spaces = prosecution_case_urns.select { _1.include?(" ") }
        return unless with_spaces.any?

        user_friendly = with_spaces.map { "'#{_1}'" }.to_sentence
        raise ::Errors::DefendantError.new("Defendant ID #{defendant_id} associated with unrecognised URN(s) #{user_friendly}",
                                           :spaces_in_urn)
      end

      def load_from_common_platform(urn)
        results = CommonPlatform::Api::SearchProsecutionCase.call(prosecution_case_reference: urn)

        # Very occasionally this case-insensitive URN search will return 2 results, so we
        # insist on the one that matches the URN exactly, as the URN we are sending here
        # comes from our existing copies of Common Platform data so should always be an
        # exact match.
        results.find { it.body["prosecutionCaseReference"] == urn }
      end

      attr_reader :defendant_id
    end
  end
end
