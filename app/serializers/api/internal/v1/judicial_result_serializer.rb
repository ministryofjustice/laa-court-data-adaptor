module Api
  module Internal
    module V1
      class JudicialResultSerializer
        include JSONAPI::Serializer

        attributes :id, :cjs_code, :text, :label, :is_adjournment_result, :is_financial_result
      end
    end
  end
end
