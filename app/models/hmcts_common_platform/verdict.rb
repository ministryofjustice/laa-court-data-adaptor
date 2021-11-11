module HmctsCommonPlatform
  class Verdict
    attr_reader :data

    delegate :blank?, to: :data

    delegate :id,
             :description,
             :category,
             :category_type,
             :cjs_verdict_code,
             :verdict_code,
             :sequence,
             to: :verdict_type,
             prefix: true

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def offence_id
      data[:offenceId]
    end

    def verdict_date
      data[:verdictDate]
    end

    def originating_hearing_id
      data[:originatingHearingId]
    end

    def verdict_type
      HmctsCommonPlatform::VerdictType.new(data[:verdictType])
    end
  end
end
