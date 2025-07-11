# frozen_string_literal: true

class RepresentationOrderContract < Dry::Validation::Contract
  option :uuid_validator, default: -> { CommonPlatform::UuidValidator }
  config.validate_keys = true

  STATUS_CODES = %w[AP FB FJ FM WD G2 GQ GR].freeze

  json do
    required(:maat_reference).value(:integer, lt?: 999_999_999)
    required(:defence_organisation).hash do
      required(:organisation).hash do
        required(:name).filled(:string)
        optional(:address).hash do
          required(:address1).filled(:string)
          optional(:address2).maybe(:string)
          optional(:address3).maybe(:string)
          optional(:address4).maybe(:string)
          optional(:address5).maybe(:string)
          optional(:postcode).maybe(:string)
        end
        optional(:contact).hash do
          optional(:home).maybe(:string)
          optional(:work).maybe(:string)
          optional(:mobile).maybe(:string)
          optional(:primary_email).maybe(:string)
          optional(:secondary_email).maybe(:string)
          optional(:fax).maybe(:string)
        end
      end
      required(:laa_contract_number).filled(:string)
      optional(:sra_number).maybe(:string)
      optional(:bar_council_membership_number).maybe(:string)
      optional(:incorporation_number).maybe(:string)
      optional(:registered_charity_number).maybe(:string)
    end
    required(:defendant_id).value(:string)
    required(:offences).array(:hash) do
      required(:offence_id).value(:string)
      required(:status_code).value(:string)
      optional(:status_date).maybe(:date)
      optional(:effective_start_date).maybe(:date)
      optional(:effective_end_date).maybe(:date)
    end
  end

  rule(:defendant_id) do
    key.failure("is not a valid uuid") unless uuid_validator.call(uuid: value)
  end

  rule(:offences).each do
    key.failure("is not a valid uuid") unless uuid_validator.call(uuid: value[:offence_id])
    key.failure("is not a valid status") unless STATUS_CODES.include? value[:status_code]
    key.failure("this status requires a status date") if value[:status_code] != "AP" && value[:status_date].blank?
    key.failure("this status requires an effective start date") if value[:status_code] != "AP" && value[:effective_start_date].blank?
  end
end
