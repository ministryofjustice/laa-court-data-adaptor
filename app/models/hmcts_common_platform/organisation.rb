module HmctsCommonPlatform
  class Organisation
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def name
      data[:name]
    end

    def incorporation_number
      data[:incorporationNumber]
    end

    def registered_charity_number
      data[:registeredCharityNumber]
    end

    def address
      HmctsCommonPlatform::Address.new(data[:address])
    end

    def contact
      HmctsCommonPlatform::ContactDetails.new(data[:contact])
    end

    def to_json(*_args)
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |organisation|
        organisation.name name
        organisation.incorporation_number incorporation_number
        organisation.registered_charity_number registered_charity_number
        organisation.address address.to_json
        organisation.contact contact.to_json
      end
    end
  end
end
