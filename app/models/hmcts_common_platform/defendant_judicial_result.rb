module HmctsCommonPlatform
  class DefendantJudicialResult
    attr_reader :data

    delegate :blank?, to: :data
    delegate :id, :cjs_code, :ordered_date, :text, to: :judicial_result

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def defendant_id
      data[:masterDefendantId]
    end

    def judicial_result
      HmctsCommonPlatform::JudicialResult.new(data[:judicialResult])
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
      Jbuilder.new do |djr|
        djr.defendant_id defendant_id
        djr.judicial_result judicial_result.to_json
      end
    end
  end
end
