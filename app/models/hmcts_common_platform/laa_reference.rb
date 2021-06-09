module HmctsCommonPlatform
  class LaaReference
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def application_reference
      data[:applicationReference]
    end

    def status_code
      data[:statusCode]
    end

    def status_date
      data[:statusDate]
    end

    def status_description
      data[:statusDescription]
    end

    def effective_end_date
      data[:effectiveEndDate]
    end

    def laa_contract_number
      data[:laaContractNumber]
    end
  end
end
