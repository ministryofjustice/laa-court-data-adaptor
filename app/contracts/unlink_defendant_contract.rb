# frozen_string_literal: true

class UnlinkDefendantContract < Dry::Validation::Contract
  option :uuid_validator, default: -> { CommonPlatform::UuidValidator }

  json do
    required(:defendant_id).value(:string)
    required(:user_name).value(:string)
    required(:unlink_reason_code).value(:integer)
    required(:unlink_reason_text).value(:string)
  end

  rule(:defendant_id) do
    key.failure('is not a valid uuid') unless uuid_validator.call(uuid: value)
  end

  rule(:user_name) do
    key.failure('must not exceed 10 characters') if value.length > 10
  end
end
