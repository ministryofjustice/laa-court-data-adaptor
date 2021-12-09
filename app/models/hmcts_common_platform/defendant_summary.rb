module HmctsCommonPlatform
  class DefendantSummary
    attr_reader :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:defendantId]
    end

    def name
      data[:defendantName] || [first_name, middle_name, last_name].join(" ").squish
    end

    def first_name
      data[:defendantFirstName]
    end

    def middle_name
      data[:defendantMiddleName]
    end

    def last_name
      data[:defendantLastName]
    end

    def arrest_summons_number
      data[:defendantASN]
    end

    def date_of_birth
      data[:defendantDOB]
    end

    def national_insurance_number
      data[:defendantNINO]
    end

    def offence_summaries
      Array(data[:offenceSummary]).map do |offence_summary_data|
        HmctsCommonPlatform::OffenceSummary.new(offence_summary_data)
      end
    end
  end
end
