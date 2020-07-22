class ProviderSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :role
end
