# frozen_string_literal: true

class NewRepresentationOrderContract < Dry::Validation::Contract
  option :email_validator, default: -> { CommonPlatform::EmailValidator }
  option :phone_validator, default: -> { CommonPlatform::PhoneValidator }
  option :postcode_validator, default: -> { CommonPlatform::PostcodeValidator }
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
      required(:status_date).value(:date)
      required(:effective_start_date).value(:date)
      optional(:effective_end_date).value(:date)
    end
  end

  rule(:defendant_id) do
    key.failure('is not a valid uuid') unless uuid_validator.call(uuid: value)
  end

  rule('defence_organisation.organisation.address.postcode') do
    key.failure('is not a valid postcode') if [key?, !postcode_validator.call(postcode: value)].all?
  end

  rule('defence_organisation.organisation.contact.primary_email') do
    key.failure('is not a valid email') if [key?, !email_validator.call(email: value)].all?
  end

  rule('defence_organisation.organisation.contact.secondary_email') do
    key.failure('is not a valid email') if [key?, !email_validator.call(email: value)].all?
  end

  rule('defence_organisation.organisation.contact.home') do
    key.failure('is not a valid phone number') if [key?, !phone_validator.call(phone: value)].all?
  end

  rule('defence_organisation.organisation.contact.mobile') do
    key.failure('is not a valid phone number') if [key?, !phone_validator.call(phone: value)].all?
  end

  rule(:offences).each do
    key.failure('is not a valid uuid') unless uuid_validator.call(uuid: value[:offence_id])
    key.failure('is not a valid status') unless STATUS_CODES.include? value[:status_code]
  end
end
