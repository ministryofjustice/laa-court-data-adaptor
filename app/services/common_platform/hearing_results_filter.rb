module CommonPlatform
  class HearingResultsFilter < ApplicationService
    def initialize(hearing_results_body, defendant_id: nil)
      @body = hearing_results_body.deep_stringify_keys
      @defendant_id = defendant_id
    end

    def call
      return @body unless @defendant_id

      @body["hearing"]["prosecutionCases"] = @body["hearing"]["prosecutionCases"]&.map do |prosecution_case|
        prosecution_case.merge(
          "defendants" => prosecution_case["defendants"].select { |defendant| defendant["id"] == @defendant_id },
        )
      end

      @body
    end
  end
end
