module CommonPlatform
  module Api
    class ProsecutionCaseFinder < ApplicationService
      def initialize(urn)
        @urn = urn
      end

      def call
        results = CommonPlatform::Api::SearchProsecutionCase.call(prosecution_case_reference: urn)

        # Very occasionally this case-insensitive URN search will return 2 results, so we
        # insist on the one that matches the URN exactly, as the URN we are sending here
        # comes from our existing copies of Common Platform data so should always be an
        # exact match.
        results.find { it.prosecution_case_reference == urn }
      end

    private

      attr_reader :urn
    end
  end
end
