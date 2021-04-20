# frozen_string_literal: true

module Api
  module Internal
    module V1
      class CrackedIneffectiveTrialSerializer
        include JSONAPI::Serializer
        set_type :cracked_ineffective_trial

        attributes :id, :code, :type, :description
      end
    end
  end
end
