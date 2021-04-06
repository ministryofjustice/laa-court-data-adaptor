module HmctsCommonPlatform
  class Offence
    attr_reader :data

    def initialize(data)
      @data = data
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
      data[:judicialResults]&.map do |judicial_result_data|
        HmctsCommonPlatform::JudicialResult.new(judicial_result_data)
      end
    end

    def plea
      HmctsCommonPlatform::Plea.new(data[:plea]) if data[:plea]
    end

    def verdict_offence_id
      data.dig(:verdict, :offenceId)
    end

    def verdict_date
      data.dig(:verdict, :verdictDate)
    end

    def verdict_type_category
      data.dig(:verdict, :verdictType, :category)
    end

    def verdict_type_category_type
      data.dig(:verdict, :verdictType, :categoryType)
    end

    def verdict_type_cjs_verdict_code
      data.dig(:verdict, :verdictType, :cjsVerdictCode)
    end

    def verdict_type_verdict_code
      data.dig(:verdict, :verdictType, :verdictCode)
    end
  end
end
