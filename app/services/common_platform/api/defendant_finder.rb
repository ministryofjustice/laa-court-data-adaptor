# frozen_string_literal: true

module CommonPlatform
  module Api
    # Note that this service can be _slow_ because it loads all hearing results
    # related to a defendant in order to populate the plea history
    class DefendantFinder < ApplicationService
      def initialize(defendant_id:, urn:)
        @defendant_id = defendant_id
        @urn = urn
      end

      def call
        return unless urn

        prosecution_case = ProsecutionCaseFinder.call(urn, defendant_id)
        return unless prosecution_case

        # This will trigger several calls to HMCTS to load results for every
        # relevant hearing in order to construct a plea history and history
        # of mode of trial reasons
        prosecution_case&.load_hearing_results(defendant_id, load_events: false)

        prosecution_case.defendants&.find { |d| d.id.eql?(defendant_id) }
      end

    private

      attr_reader :defendant_id, :urn
    end
  end
end
