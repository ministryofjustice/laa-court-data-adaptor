# frozen_string_literal: true

module Api
  module Internal
    module V1
      class DefendantSerializer
        include JSONAPI::Serializer
        set_type :defendants

        attributes :full_name,
                   :date_of_birth,
                   :national_insurance_number,
                   :arrest_summons_number,
                   :maat_reference,
                   :prosecution_case_id

        has_many :offences, record_type: :offences
        has_many :judicial_results, record_type: :judicial_results

        has_one :defence_organisation, record_type: :defence_organisations
        has_one :prosecution_case, record_type: :prosecution_case
      end
    end
  end
end
