# frozen_string_literal: true

module Api
  module Internal
    module V2
      class DefendantJudicialResultSerializer
        include JSONAPI::Serializer

        attributes :id,
                   :defendant_id,
                   :cjs_code,
                   :ordered_date,
                   :text
      end
    end
  end
end
