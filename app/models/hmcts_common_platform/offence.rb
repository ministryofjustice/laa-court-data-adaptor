module HmctsCommonPlatform
  class Offence
    attr_reader :data

    delegate :blank?, to: :data

    delegate :reference, :status_code, :status_date, :status_description, :laa_contract_number, :effective_end_date, to: :laa_application, prefix: true

    def initialize(data, defendant_id = nil)
      @data = HashWithIndifferentAccess.new(data || {})
      @defendant_id = defendant_id
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

    def legislation
      data[:offenceLegislation]
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

    delegate :mot_reason_code, to: :allocation_decision, prefix: true

    def allocation_decision
      HmctsCommonPlatform::AllocationDecision.new(data[:allocationDecision])
    end

    def judicial_result_ids
      judicial_results.map(&:id)
    end

    def judicial_results
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

    def to_json(*_args)
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |offence|
        offence.id id
        offence.code code
        offence.title title
        offence.legislation legislation
        offence.mode_of_trial mode_of_trial
        offence.wording wording
        offence.start_date start_date
        offence.order_index order_index
        offence.allocation_decision allocation_decision.to_json
        offence.plea plea.to_json
        offence.verdict verdict.to_json
        offence.judicial_results judicial_results.map(&:to_json)
        offence.laa_application laa_application.to_json
      end
    end

    def laa_application
      HmctsCommonPlatform::LaaReference.new(data[:laaApplnReference], @defendant_id)
    end
  end
end
