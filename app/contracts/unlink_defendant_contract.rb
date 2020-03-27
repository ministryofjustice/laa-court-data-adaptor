# frozen_string_literal: true

class UnlinkDefendantContract < ApplicationContract
  params do
    required(:defendant_id).value(:string)
    required(:user_name).value(:string)
    required(:unlink_reason_code).value(:integer)
    required(:unlink_reason_text).value(:string)
  end

  rule(:defendant_id).validate(:uuid)

  rule(:user_name) do
    key.failure('must not exceed 10 characters') if value.length > 10
  end
end
