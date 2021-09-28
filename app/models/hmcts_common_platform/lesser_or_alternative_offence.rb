module HmctsCommonPlatform
  class LesserOrAlternativeOffence
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def offence_definition_id
      data[:offenceDefinitionId]
    end

    def code
      data[:offenceCode]
    end

    def title
      data[:offenceTitle]
    end

    def title_welsh
      data[:offenceTitleWelsh]
    end

    def legislation
      data[:offenceLegislation]
    end

    def legislation_welsh
      data[:offenceLegislationWelsh]
    end
  end
end
