# frozen_string_literal: true

class HearingSerializer
  include FastJsonapi::ObjectSerializer
  set_type :hearings

  attributes :court_name, :hearing_type, :defendant_names, :judge_names, :prosecution_advocate_names, :defence_advocate_names, :hearing_time, :provider_names, :provider_status

  has_many :hearing_events, record_type: :hearing_events
end
