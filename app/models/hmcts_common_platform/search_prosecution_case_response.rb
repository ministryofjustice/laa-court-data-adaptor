module HmctsCommonPlatform
  class SearchProsecutionCaseResponse
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def cases
      Array(data[:cases]).map do |case_summary_data|
        HmctsCommonPlatform::ProsecutionCaseSummary.new(case_summary_data)
      end
    end

    def total_results
      data[:totalResults]
    end
  end
end
