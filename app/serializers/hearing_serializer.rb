# frozen_string_literal: true

class HearingSerializer
  include FastJsonapi::ObjectSerializer
  set_type :hearings

  attributes :court_name, :hearing_type, :defendant_names
end
