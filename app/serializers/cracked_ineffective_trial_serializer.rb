# frozen_string_literal: true

class CrackedIneffectiveTrialSerializer
  include JSONAPI::Serializer
  set_type :cracked_ineffective_trial

  attributes :id, :code, :type, :description
end
