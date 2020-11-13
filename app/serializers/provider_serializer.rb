# frozen_string_literal: true

class ProviderSerializer
  include FastJsonapi::ObjectSerializer
  set_type :providers

  attributes :name, :role
end
