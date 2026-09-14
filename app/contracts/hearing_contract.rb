# frozen_string_literal: true

class HearingContract < ApplicationContract
  option :uuid_validator, default: -> { CommonPlatform::UuidValidator }

  JURISDICTION_TYPES = %w[MAGISTRATES CROWN].freeze

  json do
    required(:hearing).hash do
      required(:id).value(:string)
      required(:jurisdictionType).value(:string)
      required(:courtCentre).hash do
        required(:id).value(:string)
      end
      required(:type).hash do
        required(:id).value(:string)
        required(:description).value(:string)
      end
      optional(:hearingDays).array(:hash) do
        required(:sittingDay).value(:date_time)
        optional(:listingSequence).value(:integer)
        required(:listedDurationMinutes).value(:integer)
      end
    end
    required(:sharedTime).value(:date_time)
  end

  rule("hearing.id") do
    key.failure(:uuid) unless uuid_validator.call(uuid: value)
  end

  rule("hearing.jurisdictionType") do
    key.failure(:invalid_jurisdiction_type) unless JURISDICTION_TYPES.include? value
  end

  rule("hearing.courtCentre.id") do
    key.failure(:uuid) unless uuid_validator.call(uuid: value)
  end

  rule("hearing.type.id") do
    key.failure(:uuid) unless uuid_validator.call(uuid: value)
  end
end
