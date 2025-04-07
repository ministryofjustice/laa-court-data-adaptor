class NewCourtApplicationLaaReferenceContract < Dry::Validation::Contract
  option :uuid_validator, default: -> { CommonPlatform::UuidValidator }
  option :maat_reference_validator, default: -> { MaatApi::MaatReferenceValidator }
  option :link_validator, default: -> { CouertApplicationLinkValidator }

  params do
    optional(:maat_reference).value(:integer, lt?: 999_999_999)
    required(:user_name).value(:string, min_size?: 1, max_size?: 10)
    required(:subject_id).value(:string)
  end

  rule(:subject_id) do
    key.failure("is not a valid uuid") unless uuid_validator.call(uuid: value)
    unless link_validator.call(subject_id: value)
      key.failure("cannot be linked right now as we do not have all the required information, please try again later")
    end
  end

  rule(:maat_reference) do
    validation = maat_reference_validator.call(maat_reference: value) if value
    key.failure(validation.body["message"]) if validation && validation.status != 200
  end
end
