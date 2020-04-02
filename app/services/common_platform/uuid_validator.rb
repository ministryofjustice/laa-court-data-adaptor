# frozen_string_literal: true

module CommonPlatform
  class UuidValidator < ApplicationService
    def initialize(uuid:)
      @uuid = uuid
    end

    def call
      JSON::Validator.validate(schema, uuid, validate_schema: true)
    end

    private

    attr_reader :uuid

    def schema
      {
        "type": 'string',
        "pattern": '[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$'
      }
    end
  end
end
