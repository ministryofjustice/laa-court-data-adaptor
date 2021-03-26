module HmctsCommonPlatform
  class CourtApplication
    attr_reader :data

    def initialize(data)
      @data = data
    end

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

    def received_date
      data[:applicationReceivedDate]
    end

    def defendant_asn
      person_defendant&.dig(:arrestSummonsNumber)
    end

    def defendant_first_name
      defendant_details&.dig(:firstName)
    end

    def defendant_last_name
      defendant_details&.dig(:lastName)
    end

    def defendant_date_of_birth
      defendant_details&.dig(:dateOfBirth)
    end

    def defendant_nino
      defendant_details&.dig(:nationalInsuranceNumber)
    end

    def defendant_documentation_language_needs
      defendant_details&.dig(:documentationLanguageNeeds)
    end

    def defendant_address_1
      defendant_address&.dig(:address1)
    end

    def defendant_address_2
      defendant_address&.dig(:address2)
    end

    def defendant_address_3
      defendant_address&.dig(:address3)
    end

    def defendant_address_4
      defendant_address&.dig(:address4)
    end

    def defendant_address_5
      defendant_address&.dig(:address5)
    end

    def defendant_postcode
      defendant_address&.dig(:postcode)
    end

    def defendant_phone_home
      defendant_contact_details&.dig(:home)
    end

    def defendant_phone_work
      defendant_contact_details&.dig(:work)
    end

    def defendant_phone_mobile
      defendant_contact_details&.dig(:mobile)
    end

    def defendant_email_primary
      defendant_contact_details&.dig(:primaryEmail)
    end

    def defendant_email_secondary
      defendant_contact_details&.dig(:secondaryEmail)
    end

    def judicial_results
      data[:judicialResults]&.map do |judicial_result_data|
        HmctsCommonPlatform::JudicialResult.new(judicial_result_data)
      end
    end

    def person_defendant
      data.dig(:applicant, :masterDefendant, :personDefendant)
    end

  private

    def defendant_address
      person_defendant&.dig(:personDetails, :address)
    end

    def defendant_contact_details
      person_defendant&.dig(:personDetails, :contact)
    end

    def defendant_details
      person_defendant&.dig(:personDetails)
    end
  end
end
