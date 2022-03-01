module HmctsCommonPlatform
  class RepresentationOrder
    attr_reader :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def application_reference
      data[:applicationReference]
    end

    def effective_start_date
      data[:effectiveFromDate]
    end

    def effective_end_date
      data[:effectiveToDate]
    end

    def laa_contract_number
      data[:laaContractNumber]
    end

    def to_json(*_args)
      to_builder.attributes!.compact
    end

  private

    def to_builder
      Jbuilder.new do |rep_order|
        rep_order.laa_application_reference application_reference
        rep_order.effective_start_date effective_start_date
        rep_order.effective_end_date effective_end_date
        rep_order.laa_contract_number laa_contract_number
      end
    end
  end
end
