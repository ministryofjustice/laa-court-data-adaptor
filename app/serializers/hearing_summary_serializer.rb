# frozen_string_literal: true

class HearingSummarySerializer
  include FastJsonapi::ObjectSerializer
  set_type :hearing_summaries

  attributes :hearing_type_description, :hearing_days
end
