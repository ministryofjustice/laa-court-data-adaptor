# frozen_string_literal: true

module Api
  module Internal
    module V1
      class ProviderSerializer
        include JSONAPI::Serializer

        attributes :name, :role
      end
    end
  end
end
