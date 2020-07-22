# frozen_string_literal: true

class ProviderSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :role
end
