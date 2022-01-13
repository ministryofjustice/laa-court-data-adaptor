# frozen_string_literal: true

module Api
  module Internal
    module V1
      class ProsecutionCaseSerializer
        include JSONAPI::Serializer
        set_type :prosecution_cases

        attributes :prosecution_case_reference

        has_many :defendants, record_type: :defendants
      end
    end
  end
end
