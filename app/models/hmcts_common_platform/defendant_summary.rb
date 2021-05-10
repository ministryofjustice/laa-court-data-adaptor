module HmctsCommonPlatform
  class DefendantSummary
    attr_reader :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def defendant_id
      data[:defendantId]
    end

    def name
      data[:defendantName]
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
