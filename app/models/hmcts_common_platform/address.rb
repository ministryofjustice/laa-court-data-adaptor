module HmctsCommonPlatform
  class Address
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def address_1
      data[:address1]
    end

    def address_2
      data[:address2]
    end

    def address_3
      data[:address3]
    end

    def address_4
      data[:address4]
    end

    def address_5
      data[:address5]
    end

    def postcode
      data[:postcode]
    end

    def to_json(*_args)
      return {} if attrs.all? { |_k, v| v.blank? }

      attrs
    end

  private

    def attrs
      @attrs ||= to_builder.attributes!
    end

    def to_builder
      Jbuilder.new do |address|
        address.address_1 address_1
        address.address_2 address_2
        address.address_3 address_3
        address.address_4 address_4
        address.address_5 address_5
        address.postcode postcode
      end
    end
  end
end
