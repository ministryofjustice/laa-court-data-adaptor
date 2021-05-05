module HmctsCommonPlatform
  class Plea
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def originating_hearing_id
      data[:originatingHearingId]
    end

    def delegated_powers
      HmctsCommonPlatform::DelegatedPowers.new(data[:delegatedPowers])
    end

    def offence_id
      data[:offenceId]
    end

    def application_id
      data[:applicationId]
    end

    def plea_date
      data[:pleaDate]
    end

    def plea_value
      data[:pleaValue]
    end

    def lesser_or_alternative_offence
      HmctsCommonPlatform::LesserOrAlternativeOffence.new(data[:lesserOrAlternativeOffence])
    end
  end
end
