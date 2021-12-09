# frozen_string_literal: true

module CommonPlatform
  module Api
    class DefendantSummary
      def self.get(prosecution_case_reference:, defendant_id:)
        data = ProsecutionCaseSearcher.call(prosecution_case_reference: prosecution_case_reference).body["cases"].first
        prosecution_case_summary = HmctsCommonPlatform::ProsecutionCaseSummary.new(data)

        prosecution_case_summary.defendant_summaries.find do |ds|
          ds.id == defendant_id
        end
      end
    end
  end
end
