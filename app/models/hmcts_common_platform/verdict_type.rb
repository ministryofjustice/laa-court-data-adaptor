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

    def to_json(*_args)
      return {} if attrs.all? { |_k, v| v.blank? }

      attrs
    end

  private

    def attrs
      @attrs ||= to_builder.attributes!
    end

    def to_builder
      Jbuilder.new do |verdict_type|
        verdict_type.id id
        verdict_type.description description
        verdict_type.category category
        verdict_type.category_type category_type
        verdict_type.cjs_verdict_code cjs_verdict_code
        verdict_type.verdict_code verdict_code
        verdict_type.sequence sequence
      end
    end
  end
end
