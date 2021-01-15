# frozen_string_literal: true

class HearingSummarySerializer
  include JSONAPI::Serializer
  set_type :hearing_summaries

  attributes :hearing_type, :hearing_days
end
