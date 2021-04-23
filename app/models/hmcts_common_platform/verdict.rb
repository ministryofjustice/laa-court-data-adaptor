module HmctsCommonPlatform
  class Verdict
    attr_reader :data

    def initialize(data)
      @data = data || {}
    end

    delegate :blank?, to: :data

    def offence_id
      data[:offenceId]
    end

    def verdict_date
      data[:verdictDate]
    end

    def verdict_type_category
      data.dig(:verdictType, :category)
    end

    def verdict_type_category_type
      data.dig(:verdictType, :categoryType)
    end

    def verdict_type_cjs_verdict_code
      data.dig(:verdictType, :cjsVerdictCode)
    end

    def verdict_type_verdict_code
      data.dig(:verdictType, :verdictCode)
    end
  end
end
