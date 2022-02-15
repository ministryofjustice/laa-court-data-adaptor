module HmctsCommonPlatform
  class DefenceOrganisation
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def organisation
      HmctsCommonPlatform::Organisation.new(data[:organisation])
    end

    def laa_contract_number
      data[:laaContractNumber]
    end

    def to_json(*_args)
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |defence_organisation|
        defence_organisation.organisation organisation.to_json
        defence_organisation.laa_contract_number laa_contract_number
      end
    end
  end
end
