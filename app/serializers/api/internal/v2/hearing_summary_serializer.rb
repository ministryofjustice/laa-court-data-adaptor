# frozen_string_literal: true

module Api
  module Internal
    module V2
      class HearingSummarySerializer
        include JSONAPI::Serializer
        set_type :hearing_summaries

        attributes :hearing_type, :hearing_days
      end
    end
  end
end
