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
  end
end
