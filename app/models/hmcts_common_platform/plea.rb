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

    def to_json(*_args)
      return {} if attrs.all? { |_k, v| v.blank? }

      attrs
    end

  private

    def attrs
      @attrs ||= to_builder.attributes!
    end

    def to_builder
      Jbuilder.new do |plea|
        plea.date plea_date
        plea.value plea_value
        plea.originating_hearing_id originating_hearing_id
        plea.offence_id offence_id
        plea.application_id application_id
        plea.delegated_powers delegated_powers.to_json
      end
    end
  end
end
