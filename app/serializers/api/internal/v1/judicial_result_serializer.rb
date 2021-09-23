module Api
  module Internal
    module V1
      class JudicialResultSerializer
        include JSONAPI::Serializer

        attributes :id,
          :cjs_code,
          :is_adjournement_result,
          :is_available_for_court_extract,
          :is_convicted_result,
          :is_financial_result,
          :label,
          :ordered_date,
          :qualifier,
          :text
      end
    end
  end
end
