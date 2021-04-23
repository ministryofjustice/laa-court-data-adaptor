module HmctsCommonPlatform
  class Defendant
    attr_reader :data

    delegate :blank?, to: :data

    delegate :arrest_summons_number, :first_name, :last_name, :date_of_birth, :documentation_language_needs, :address_1, :address_2, :address_3, :address_4, :address_5, :postcode, :nino, :phone_home, :phone_work, :phone_mobile, :email_primary, :email_secondary, to: :person_defendant

    def initialize(data)
      @data = data || {}
    end

    def proceedings_concluded
      data[:proceedingsConcluded]
    end

    def offences
      Array(data[:offences]).map do |offence_data|
        HmctsCommonPlatform::Offence.new(offence_data)
      end
    end

  private

    def person_defendant
      HmctsCommonPlatform::PersonDefendant.new(data[:personDefendant])
    end
  end
end
