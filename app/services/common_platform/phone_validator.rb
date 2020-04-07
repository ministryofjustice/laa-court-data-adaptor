# frozen_string_literal: true

module CommonPlatform
  class PhoneValidator < ApplicationService
    def initialize(phone:)
      @phone = phone
    end

    def call
      JSON::Validator.validate(schema, phone, validate_schema: true)
    end

    private

    attr_reader :phone

    def schema
      {
        "type": 'string',
        "pattern": '^[\\+]?[0-9()\\-\\.\\s]+$'
      }
    end
  end
end
