# frozen_string_literal: true

module Api
  module Internal
    module V1
      class HearingEventSerializer
        include JSONAPI::Serializer
        set_type :hearing_events

        attributes :description
        attributes :occurred_at
        attributes :note
      end
    end
  end
end
