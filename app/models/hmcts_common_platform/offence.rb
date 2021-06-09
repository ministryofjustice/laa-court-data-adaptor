module HmctsCommonPlatform
  class Offence
    attr_reader :data

    delegate :blank?, to: :data

    delegate :application_reference, :status_code, :status_date, :status_description, :laa_contract_number, :effective_end_date, to: :laa_reference, prefix: true

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:id]
    end

    def offence_code
      data[:offenceCode]
    end

    def order_index
      data[:orderIndex]
    end

    def offence_title
      data[:offenceTitle]
    end

    def mode_of_trial
      data[:modeOfTrial]
    end

    def start_date
      data[:startDate]
    end

    def wording
      data[:wording]
    end

    def allocation_decision_mot_reason_code
      data.dig(:allocationDecision, :motReasonCode)
    end

    def results
      Array(data[:judicialResults]).map do |judicial_result_data|
        HmctsCommonPlatform::JudicialResult.new(judicial_result_data)
      end
    end

    def plea
      HmctsCommonPlatform::Plea.new(data[:plea])
    end

    def verdict
      HmctsCommonPlatform::Verdict.new(data[:verdict])
    end

  private

    def laa_reference
      HmctsCommonPlatform::LaaReference.new(data[:laaApplnReference])
    end
  end
end
