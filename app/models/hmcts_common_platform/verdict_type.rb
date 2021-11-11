module HmctsCommonPlatform
  class VerdictType
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:id]
    end

    def description
      data[:description]
    end

    def category
      data[:category]
    end

    def category_type
      data[:categoryType]
    end

    def cjs_verdict_code
      data[:cjsVerdictCode]
    end

    def verdict_code
      data[:verdictCode]
    end

    def sequence
      data[:sequence]
    end
  end
end
