# frozen_string_literal: true

class HearingSerializer
  include FastJsonapi::ObjectSerializer
  set_type :hearings

  attributes :court_name,
             :hearing_type,
             :hearing_type_description,
             :hearing_days,
             :defendant_names,
             :judge_names,
             :prosecution_advocate_names,
             :defence_advocate_names

  has_many :hearing_events, record_type: :hearing_events
  has_many :providers, record_type: :providers
end
