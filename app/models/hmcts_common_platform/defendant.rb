module HmctsCommonPlatform
  class Defendant
    attr_reader :data

    delegate :blank?, to: :data

    delegate :arrest_summons_number, :first_name, :last_name, :date_of_birth, :documentation_language_needs, :address_1, :address_2, :address_3, :address_4, :address_5, :postcode, :nino, :phone_home, :phone_work, :phone_mobile, :email_primary, :email_secondary, to: :person_defendant

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:id]
    end

    def proceedings_concluded
      data[:proceedingsConcluded]
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

    def prosecution_case; end

    def name; end

    def national_insurance_number; end

    def maat_reference; end

    def post_hearing_custody_statuses; end

    def defence_organisation_id; end

    def prosecution_case_id; end

  private

    def person_defendant
      HmctsCommonPlatform::PersonDefendant.new(data[:personDefendant])
    end
  end
end
