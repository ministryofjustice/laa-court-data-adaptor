# frozen_string_literal: true

class ProviderSerializer
  include JSONAPI::Serializer
  set_type :providers

  attributes :name, :role
end
