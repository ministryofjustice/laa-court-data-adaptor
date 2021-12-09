# frozen_string_literal: true

module Api
  module Internal
    module V2
      class DefendantSummarySerializer
        include JSONAPI::Serializer

        attributes :name,
                   :date_of_birth,
                   :national_insurance_number,
                   :arrest_summons_number
      end
    end
  end
end
