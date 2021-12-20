# frozen_string_literal: true

module Api
  module Internal
    module V1
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

        has_many :hearing_events
        has_many :providers
        has_many :court_applications
        has_many :prosecution_cases
        has_many :defendant_judicial_results
        has_one :cracked_ineffective_trial
      end
    end
  end
end
