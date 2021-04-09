module HmctsCommonPlatform
  class Offence
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def id
      data[:id]
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

    def laa_reference_status_code
      data.dig(:laaApplnReference, :statusCode)
    end

    def laa_reference_status_date
      data.dig(:laaApplnReference, :statusDate)
    end

    def laa_reference_status_description
      data.dig(:laaApplnReference, :statusDescription)
    end

    def laa_reference_effective_end_date
      data.dig(:laaApplnReference, :effectiveEndDate)
    end

    def laa_reference_application_reference
      data.dig(:laaApplnReference, :applicationReference)
    end

    def judicial_results
      data[:judicialResults]&.map do |judicial_result_data|
        HmctsCommonPlatform::JudicialResult.new(judicial_result_data)
      end
    end

    def verdict
      HmctsCommonPlatform::Verdict.new(data[:verdict]) if data[:verdict]
    end

    def plea
      data[:plea]
    end
  end
end
