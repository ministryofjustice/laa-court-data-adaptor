# frozen_string_literal: true

class NewLaaReferenceContract < ApplicationContract
  params do
    optional(:maat_reference).value(:integer)
    required(:defendant_id).value(:string)
  end

  rule(:defendant_id).validate(:uuid)

  rule(:maat_reference) do
    key.failure('must not exceed 9 digits') if key? && value > 999_999_999
  end
end
