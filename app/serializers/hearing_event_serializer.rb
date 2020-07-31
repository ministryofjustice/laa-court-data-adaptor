# frozen_string_literal: true

class HearingEventSerializer
  include FastJsonapi::ObjectSerializer
  set_type :hearing_events

  attributes :description
  attributes :occurred_at
end
