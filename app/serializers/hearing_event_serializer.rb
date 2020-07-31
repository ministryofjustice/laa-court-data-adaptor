# frozen_string_literal: true

class HearingEventSerializer
  include FastJsonapi::ObjectSerializer
  set_type :hearing_events

  attributes :description
end
