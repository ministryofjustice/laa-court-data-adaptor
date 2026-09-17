# frozen_string_literal: true

class UnlinkDefendantContract < ApplicationContract
  option :uuid_validator, default: -> { CommonPlatform::UuidValidator }

  json do
    required(:defendant_id).value(:string)
    required(:user_name).value(:string, max_size?: 10)
    required(:unlink_reason_code).value(:integer)
    optional(:unlink_other_reason_text).value(:string)
  end

  rule(:defendant_id) do
    key.failure(:uuid) unless uuid_validator.call(uuid: value)
  end

  rule(:unlink_other_reason_text, :unlink_reason_code) do
    key.failure(:must_be_present) if values[:unlink_other_reason_text].blank? && values[:unlink_reason_code].eql?(7)
    key.failure(:must_be_absent) if values[:unlink_other_reason_text].present? && !values[:unlink_reason_code].eql?(7)
  end
end
