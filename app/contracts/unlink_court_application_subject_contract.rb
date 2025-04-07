class UnlinkCourtApplicationSubjectContract < Dry::Validation::Contract
  OTHER_REASON_CODE = 7
  option :uuid_validator, default: -> { CommonPlatform::UuidValidator }

  json do
    required(:subject_id).value(:string)
    required(:user_name).value(:string, max_size?: 10)
    required(:unlink_reason_code).value(:integer)
    optional(:unlink_other_reason_text).value(:string)
  end

  rule(:subject_id) do
    key.failure("is not a valid uuid") unless uuid_validator.call(uuid: value)
  end

  rule(:unlink_other_reason_text, :unlink_reason_code) do
    key.failure("must be present") if values[:unlink_other_reason_text].blank? && values[:unlink_reason_code].eql?(OTHER_REASON_CODE)
    key.failure("must be absent") if values[:unlink_other_reason_text].present? && !values[:unlink_reason_code].eql?(OTHER_REASON_CODE)
  end
end
