# frozen_string_literal: true

class CrackedIneffectiveTrialSerializer
  include FastJsonapi::ObjectSerializer
  set_type :cracked_ineffective_trial

  attributes :id, :code, :type, :description
end
