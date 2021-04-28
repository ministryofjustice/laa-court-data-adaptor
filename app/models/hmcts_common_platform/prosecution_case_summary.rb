module HmctsCommonPlatform
  class ProsecutionCaseSummary
    attr_reader :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def prosecution_case_reference
      data[:prosecutionCaseReference]
    end

    def case_status
      data[:caseStatus]
    end

    def defendant_summaries
      Array(data[:defendantSummary]).map do |defendant_summary_data|
        HmctsCommonPlatform::DefendantSummary.new(defendant_summary_data)
      end
    end

    def hearing_summaries
      Array(data[:hearingSummary]).map do |hearing_summary_data|
        HmctsCommonPlatform::HearingSummary.new(hearing_summary_data)
      end
    end
  end
end
