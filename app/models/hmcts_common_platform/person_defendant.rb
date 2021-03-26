module HmctsCommonPlatform
  class PersonDefendant
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def arrest_summons_number
      data&.dig(:arrestSummonsNumber)
    end

    def first_name
      person_details&.dig(:firstName)
    end

    def last_name
      person_details&.dig(:lastName)
    end

    def date_of_birth
      person_details&.dig(:dateOfBirth)
    end

    def nino
      person_details&.dig(:nationalInsuranceNumber)
    end

    def documentation_language_needs
      person_details&.dig(:documentationLanguageNeeds)
    end

    def address_1
      address&.dig(:address1)
    end

    def address_2
      address&.dig(:address2)
    end

    def address_3
      address&.dig(:address3)
    end

    def address_4
      address&.dig(:address4)
    end

    def postcode
      address&.dig(:postcode)
    end

    def address_5
      address&.dig(:address5)
    end

    def phone_home
      contact&.dig(:home)
    end

    def phone_work
      contact&.dig(:work)
    end

    def phone_mobile
      contact&.dig(:mobile)
    end

    def email_primary
      contact&.dig(:primaryEmail)
    end

    def email_secondary
      contact&.dig(:secondaryEmail)
    end

  private

    def address
      person_details&.dig(:address)
    end

    def contact
      person_details&.dig(:contact)
    end

    def person_details
      data&.dig(:personDetails)
    end
  end
end
