module HmctsCommonPlatform
  class Defendant
    attr_reader :data

    delegate :blank?, to: :data

    delegate :arrest_summons_number,
             :first_name,
             :last_name,
             :middle_name,
             :full_name,
             :date_of_birth,
             :documentation_language_needs,
             :address_1,
             :address_2,
             :address_3,
             :address_4,
             :address_5,
             :postcode,
             :nino,
             :phone_home,
             :phone_work,
             :phone_mobile,
             :email_primary,
             :email_secondary,
             to: :person_defendant

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:id]
    end

    def prosecution_case_id
      data[:prosecutionCaseId]
    end

    def proceedings_concluded
      data[:proceedingsConcluded]
    end

    def legal_aid_status
      data[:legalAidStatus]
    end

    def is_youth
      data[:isYouth]
    end

    def offence_ids
      offences.map(&:id)
    end

    def offences
      Array(data[:offences]).map do |offence_data|
        HmctsCommonPlatform::Offence.new(offence_data)
      end
    end

    def judicial_result_ids
      judicial_results.map(&:id)
    end

    def judicial_results
      Array(data[:judicialResults]).map do |judicial_result_data|
        HmctsCommonPlatform::JudicialResult.new(judicial_result_data)
      end
    end

    def defence_organisation
      HmctsCommonPlatform::DefenceOrganisation.new(data[:defenceOrganisation])
    end

    def to_json(*_args)
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |defendant|
        defendant.id id
        defendant.prosecution_case_id prosecution_case_id
        defendant.defendant_details person_defendant.to_json
        defendant.offences offences.map(&:to_json)
        defendant.judicial_results judicial_results.map(&:to_json)
        defendant.defence_organisation defence_organisation.to_json
        defendant.legal_aid_status legal_aid_status
        defendant.proceedings_concluded proceedings_concluded
        defendant.is_youth is_youth
      end
    end

    def person_defendant
      HmctsCommonPlatform::PersonDefendant.new(data[:personDefendant])
    end
  end
end
