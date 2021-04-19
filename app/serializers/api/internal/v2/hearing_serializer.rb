# frozen_string_literal: true

module Api
  module Internal
    module V2
      class HearingSerializer
        include JSONAPI::Serializer
        set_type :hearings

        attributes :court_name,
                   :hearing_type,
                   :hearing_days,
                   :defendant_names,
                   :judge_names,
                   :prosecution_advocate_names,
                   :defence_advocate_names

        has_many :hearing_events, record_type: :hearing_events
        has_many :providers, record_type: :providers
        has_one :cracked_ineffective_trial, record_type: :cracked_ineffective_trial
      end
    end
  end
end
