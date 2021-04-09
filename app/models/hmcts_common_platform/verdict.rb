module HmctsCommonPlatform
  class Verdict
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def offence_id
      data[:offenceId]
    end

    def date
      data[:verdictDate]
    end

    def type_category
      data.dig(:verdictType, :category)
    end

    def type_category_type
      data.dig(:verdictType, :categoryType)
    end

    def type_cjs_code
      data.dig(:verdictType, :cjsVerdictCode)
    end

    def type_code
      data.dig(:verdictType, :verdictCode)
    end
  end
end
