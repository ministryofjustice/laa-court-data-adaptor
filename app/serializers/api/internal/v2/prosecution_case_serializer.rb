# frozen_string_literal: true

module Api
  module Internal
    module V2
      class ProsecutionCaseSerializer
        include JSONAPI::Serializer
        set_type :prosecution_cases

        attributes :urn

        has_many :defendants, record_type: :defendants
      end
    end
  end
end
