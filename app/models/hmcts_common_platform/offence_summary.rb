module HmctsCommonPlatform
  class OffenceSummary
    attr_reader :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def offence_id
      data[:offenceId]
    end

    def code
      data[:offenceCode]
    end

    def order_index
      data[:orderIndex]
    end

    def mode_of_trial
      data[:modeOfTrial]
    end

    def start_date
      data[:startDate]
    end

    def title
      data[:offenceTitle]
    end

    def wording
      data[:wording]
    end
  end
end
