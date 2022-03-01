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

    def to_json(*_args)
      return {} if attrs.all? { |_k, v| v.blank? }

      attrs
    end

  private

    def attrs
      @attrs ||= to_builder.attributes!
    end

    def to_builder
      Jbuilder.new do |verdict|
        verdict.date verdict_date
        verdict.type verdict_type.to_json
        verdict.offence_id offence_id
        verdict.originating_hearing_id originating_hearing_id
      end
    end
  end
end
