# frozen_string_literal: true

module CommonPlatform
  class EmailValidator < ApplicationService
    def initialize(email:)
      @email = email
    end

    def call
      JSON::Validator.validate(schema, email, validate_schema: true)
    end

  private

    attr_reader :email

    def schema
      {
        "type": "string",
        "pattern": "^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$",
      }
    end
  end
end
