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

    def title
      data[:offenceTitle]
    end

    def legislation
      data[:offenceLegislation]
    end

    def wording
      data[:wording]
    end

    def arrest_date
      data[:arrestDate]
    end

    def charge_date
      data[:chargeDate]
    end

    def mode_of_trial
      data[:modeOfTrial]
    end

    def start_date
      data[:startDate]
    end

    def proceedings_concluded
      data[:proceedingsConcluded]
    end

    def to_json(*_args)
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |offence_summary|
        offence_summary.id offence_id
        offence_summary.code code
        offence_summary.order_index order_index
        offence_summary.mode_of_trial mode_of_trial
        offence_summary.start_date start_date
        offence_summary.title title
        offence_summary.wording wording
        offence_summary.proceedings_concluded proceedings_concluded
        offence_summary.legislation legislation
        offence_summary.arrest_date arrest_date
        offence_summary.charge_date charge_date
      end
    end
  end
end
