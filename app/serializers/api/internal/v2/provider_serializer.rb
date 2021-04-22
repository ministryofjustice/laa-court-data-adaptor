# frozen_string_literal: true

module Api
  module Internal
    module V2
      class ProviderSerializer
        include JSONAPI::Serializer
        set_type :providers

        attributes :name, :role
      end
    end
  end
end
