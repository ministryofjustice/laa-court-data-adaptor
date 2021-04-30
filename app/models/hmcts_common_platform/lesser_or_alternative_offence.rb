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

    def offence_code
      data[:offenceCode]
    end

    def offence_title
      data[:offenceTitle]
    end

    def offence_title_welsh
      data[:offenceTitleWelsh]
    end

    def offence_legislation
      data[:offenceLegislation]
    end

    def offence_legislation_welsh
      data[:offenceLegislationWelsh]
    end
  end
end
