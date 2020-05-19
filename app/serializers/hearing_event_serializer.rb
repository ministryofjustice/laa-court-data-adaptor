# frozen_string_literal: true

class HearingEventSerializer
  include FastJsonapi::ObjectSerializer

  attributes :description
end
