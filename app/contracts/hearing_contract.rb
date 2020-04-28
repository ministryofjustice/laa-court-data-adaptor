# frozen_string_literal: true

class HearingContract < Dry::Validation::Contract
  option :uuid_validator, default: -> { CommonPlatform::UuidValidator }

  JURISDICTION_TYPES = %w[MAGISTRATES CROWN].freeze
  HEARING_TYPES = %w[PLE SEN REV TRL TIS APN BRE EBW GRH STE APL PTR FCM JGT PLY PTP FHG CON].freeze

  json do
    required(:hearing).hash do
      required(:id).value(:string)
      required(:jurisdictionType).value(:string)
      required(:courtCentre).hash do
        required(:id).value(:string)
      end
      required(:type).hash do
        required(:id).value(:string)
        optional(:code).value(:string)
        optional(:description).value(:string)
      end
      required(:hearingDays).array(:hash) do
        required(:sittingDay).value(:date_time)
        optional(:listingSequence).value(:integer)
        required(:listedDurationMinutes).value(:integer)
      end
    end
    required(:sharedTime).value(:date_time)
  end

  rule('hearing.id') do
    key.failure('is not a valid uuid') unless uuid_validator.call(uuid: value)
  end

  rule('hearing.jurisdictionType') do
    key.failure('is not a valid jurisdictionType') unless JURISDICTION_TYPES.include? value
  end

  rule('hearing.courtCentre.id') do
    key.failure('is not a valid uuid') unless uuid_validator.call(uuid: value)
  end

  rule('hearing.type.id') do
    key.failure('is not a valid uuid') unless uuid_validator.call(uuid: value)
  end

  rule('hearing.type.code') do
    key.failure('is not a valid hearing code') unless !key? || (HEARING_TYPES.include? value)
  end
end
