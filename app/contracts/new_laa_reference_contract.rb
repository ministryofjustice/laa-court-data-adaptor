# frozen_string_literal: true

class NewLaaReferenceContract < Dry::Validation::Contract
  option :uuid_validator, default: -> { CommonPlatform::UuidValidator }

  params do
    optional(:maat_reference).value(:integer, lt?: 999_999_999)
    required(:defendant_id).value(:string)
  end

  rule(:defendant_id) do
    key.failure('is not a valid uuid') unless uuid_validator.call(uuid: value)
  end
end
