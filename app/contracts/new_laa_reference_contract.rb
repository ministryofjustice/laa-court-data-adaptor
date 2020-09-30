# frozen_string_literal: true

class NewLaaReferenceContract < Dry::Validation::Contract
  option :uuid_validator, default: -> { CommonPlatform::UuidValidator }
  option :maat_reference_validator, default: -> { MaatApi::MaatReferenceValidator }

  params do
    optional(:maat_reference).value(:integer, lt?: 999_999_999)
    optional(:user_name).value(:string, max_size?: 10)
    required(:defendant_id).value(:string)
  end

  rule(:defendant_id) do
    key.failure('is not a valid uuid') unless uuid_validator.call(uuid: value)
  end

  rule(:maat_reference) do
    validation = maat_reference_validator.call(maat_reference: value)
    key.failure(validation.body['message']) unless validation.status == 200
  end
end
