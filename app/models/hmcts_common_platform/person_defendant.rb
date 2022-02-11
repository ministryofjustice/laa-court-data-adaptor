module HmctsCommonPlatform
  class PersonDefendant
    attr_reader :data

    delegate :blank?, to: :data

    delegate :first_name, :last_name, :date_of_birth, :nino, :documentation_language_needs, to: :person_details
    delegate :address_1, :address_2, :address_3, :address_4, :address_5, :postcode, to: :address
    delegate :phone_home, :phone_work, :phone_mobile, :email_primary, :email_secondary, to: :contact_details

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def arrest_summons_number
      data[:arrestSummonsNumber]
    end

    def to_json(*_args)
      return {} if attrs.all? { |_k, v| v.blank? }

      attrs
    end

  private

    def to_builder
      Jbuilder.new do |person_defendant|
        person_defendant.arrest_summons_number arrest_summons_number
        person_defendant.details person_details.to_json
      end
    end

    def attrs
      @attrs ||= to_builder.attributes!
    end

    def address
      person_details.address
    end

    def contact_details
      person_details.contact_details
    end

    def person_details
      HmctsCommonPlatform::Person.new(data[:personDetails])
    end
  end
end
