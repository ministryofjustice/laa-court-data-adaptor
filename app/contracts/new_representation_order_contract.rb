# frozen_string_literal: true

class NewRepresentationOrderContract < Dry::Validation::Contract
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
          optional(:address2).filled(:string)
          optional(:address3).filled(:string)
          optional(:address4).filled(:string)
          optional(:address5).filled(:string)
          optional(:postcode).filled(:string)
        end
        optional(:contact).hash do
          optional(:home).filled(:string)
          optional(:work).filled(:string)
          optional(:mobile).filled(:string)
          optional(:primary_email).filled(:string)
          optional(:secondary_email).filled(:string)
          optional(:fax).filled(:string)
        end
      end
      required(:laa_contract_number).filled(:string)
      optional(:sra_number).filled(:string)
      optional(:bar_council_membership_number).filled(:string)
      optional(:incorporation_number).filled(:string)
      optional(:registered_charity_number).filled(:string)
    end
    required(:defendant_id).value(:string)
    required(:offences).array(:hash) do
      required(:offence_id).value(:string)
      required(:status_code).value(:string)
      optional(:status_date).value(:date)
      optional(:effective_start_date).value(:date)
      optional(:effective_end_date).value(:date)
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
