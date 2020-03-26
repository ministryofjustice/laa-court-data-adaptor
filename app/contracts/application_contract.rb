# frozen_string_literal: true

class ApplicationContract < Dry::Validation::Contract
  register_macro(:uuid) do
    key.failure('not a valid uuid') unless /\A[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}\z/.match?(value)
  end
end
