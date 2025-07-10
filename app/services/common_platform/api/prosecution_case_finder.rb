module CommonPlatform
  module Api
    # This class exists to work around two issues with search-by-URN.
    # First, case URNs are NOT case-insensitive, but Common Platform URN
    # search IS case insensitive.
    # Second, case URNs can contain spaces, but Common Platform URN
    # search strips spaces from search queries
    class ProsecutionCaseFinder < ApplicationService
      def initialize(urn, defendant_id = nil)
        @urn = urn
        @defendant_id = defendant_id
      end

      attr_reader :urn, :defendant_id

      def call
        filter_by_urn(retrieve_by_urn.presence || retrieve_by_defendant_details)
      end

      def retrieve_by_urn
        CommonPlatform::Api::SearchProsecutionCase.call(prosecution_case_reference: urn)
      end

      def retrieve_by_defendant_details
        return unless defendant_id

        # Common Platform has a known bug where sometimes URNs have spaces, but if we
        # look up by URN they strip spaces from the URN we send, which means we cannot
        # successfully look up by URN if there is a space in the URN
        local_record = ProsecutionCaseDefendantOffence.find_by(defendant_id:)&.prosecution_case
        return unless local_record&.prosecution_case_reference == urn

        local_defendant = local_record.defendants.find { it.id == defendant_id }
        return unless local_defendant

        CommonPlatform::Api::SearchProsecutionCase.call(
          name: local_defendant.name,
          date_of_birth: local_defendant.date_of_birth,
        )
      end

      def filter_by_urn(results)
        return unless results

        # Very occasionally this case-insensitive URN search will return 2 results, so we
        # insist on the one that matches the URN exactly, as the URN we are sending here
        # comes from our existing copies of Common Platform data so should always be an
        # exact match.
        results.find { it.prosecution_case_reference == urn }
      end
    end
  end
end
