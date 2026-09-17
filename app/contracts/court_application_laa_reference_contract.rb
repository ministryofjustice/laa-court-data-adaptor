class CourtApplicationLaaReferenceContract < ApplicationContract
  include ValidatesMaatReference

  option :uuid_validator, default: -> { CommonPlatform::UuidValidator }
  option :link_validator, default: -> { CourtApplicationLinkValidator }

  params do
    optional(:maat_reference).value(:integer, lt?: 999_999_999)
    required(:user_name).value(:string, min_size?: 1, max_size?: 10)
    required(:subject_id).value(:string)
  end

  rule(:subject_id) do
    key.failure(:uuid) unless uuid_validator.call(uuid: value)
    unless link_validator.call(subject_id: value)
      key.failure(:missing_summary_data)
    end
  end
end
