module HmctsCommonPlatform
  class CourtApplication
    attr_reader :data

    def initialize(data)
      @data = data || {}
    end

    delegate :blank?, to: :data

    def type_id
      data.dig(:type, :id)
    end

    def type_name
      data.dig(:type, :type)
    end

    def type_code
      data.dig(:type, :code)
    end

    def type_category_code
      data.dig(:type, :categoryCode)
    end

    def type_legislation
      data.dig(:type, :legislation)
    end

    def application_particulars
      data[:applicationParticulars]
    end

    def received_date
      data[:applicationReceivedDate]
    end

    def defendant_arrest_summons_number
      person_defendant.arrest_summons_number
    end

    def defendant_first_name
      person_defendant.first_name
    end

    def defendant_last_name
      person_defendant.last_name
    end

    def defendant_date_of_birth
      person_defendant.date_of_birth
    end

    def defendant_nino
      person_defendant.nino
    end

    def defendant_documentation_language_needs
      person_defendant.documentation_language_needs
    end

    def defendant_address_1
      person_defendant.address_1
    end

    def defendant_address_2
      person_defendant.address_2
    end

    def defendant_address_3
      person_defendant.address_3
    end

    def defendant_address_4
      person_defendant.address_4
    end

    def defendant_address_5
      person_defendant.address_5
    end

    def defendant_postcode
      person_defendant.postcode
    end

    def defendant_phone_home
      person_defendant.phone_home
    end

    def defendant_phone_work
      person_defendant.phone_work
    end

    def defendant_phone_mobile
      person_defendant.phone_mobile
    end

    def defendant_email_primary
      person_defendant.email_primary
    end

    def defendant_email_secondary
      person_defendant.email_secondary
    end

    def judicial_results
      data[:judicialResults]&.map do |judicial_result_data|
        HmctsCommonPlatform::JudicialResult.new(judicial_result_data)
      end
    end

  private

    def person_defendant
      HmctsCommonPlatform::PersonDefendant.new(data.dig(:applicant, :masterDefendant, :personDefendant))
    end
  end
end
