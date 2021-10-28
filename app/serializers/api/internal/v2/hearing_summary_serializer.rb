# frozen_string_literal: true

module Api
  module Internal
    module V2
      class HearingSummarySerializer
        include JSONAPI::Serializer
        attributes :hearing_type

        attribute :hearing_days do |hearing_summary|
          hearing_summary.sitting_days.map do |day|
            Date.parse(day).to_formatted_s(:db)
          end
        end

        attribute :court_centre do |hearing_summary|
          {
            name: hearing_summary.court_centre.name,
          }
        end
      end
    end
  end
end
