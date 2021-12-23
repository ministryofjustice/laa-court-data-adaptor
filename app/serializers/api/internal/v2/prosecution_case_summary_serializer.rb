# frozen_string_literal: true

module Api
  module Internal
    module V2
      class ProsecutionCaseSummarySerializer
        include JSONAPI::Serializer
        set_type :prosecution_cases

        attributes :prosecution_case_reference

        has_many :defendants, record_type: :defendants
        has_many :hearing_summaries, record_type: :hearing_summaries
      end
    end
  end
end
