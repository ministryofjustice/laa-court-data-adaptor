# frozen_string_literal: true

module Api
  module Internal
    module V2
      class HearingSummarySerializer
        include JSONAPI::Serializer

        attributes :hearing_type, :estimated_duration

        attribute :hearing_days do |hearing_summary|
          hearing_summary.hearing_days.map do |hearing_day|
            {
              sitting_day: Date.parse(hearing_day.sitting_day).to_formatted_s(:db),
              has_shared_results: hearing_day.has_shared_results,
            }
          end
        end

        attribute :court_centre do |hearing_summary|
          {
            name: hearing_summary.court_centre.name,
          }
        end

        has_many :defence_counsels
      end
    end
  end
end
