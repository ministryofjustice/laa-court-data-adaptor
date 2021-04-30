module HmctsCommonPlatform
  class Offence
    attr_reader :data

    delegate :blank?, to: :data

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

    def laa_appln_reference_status_code
      data.dig(:laaApplnReference, :statusCode)
    end

    def laa_appln_reference_status_date
      data.dig(:laaApplnReference, :statusDate)
    end

    def laa_appln_reference_end_date
      data.dig(:laaApplnReference, :effectiveEndDate)
    end

    def laa_appln_reference_status_description
      data.dig(:laaApplnReference, :statusDescription)
    end

    def laa_appln_reference_laa_contract_number
      data.dig(:laaApplnReference, :laaContractNumber)
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
  end
end
