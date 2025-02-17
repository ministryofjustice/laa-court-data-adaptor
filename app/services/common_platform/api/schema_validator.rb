require "json-schema"
require "uri"

module CommonPlatform
  module Api
    class SchemaValidator < ApplicationService
      def initialize(schema:, json_response:)
        @schema = schema
        @json_response = json_response

        load_schema_references
      end

      def call
        JSON::Validator.validate!(@schema, @json_response)
      rescue JSON::Schema::ValidationError => e
        Rails.logger.error("JSON Schema Validation Error: #{e.message}")
        false
      end

    private

      def load_schema_references
        refs = [
          {
            filename: "lib/schemas/global/apiCourtsDefinitions.json",
            url: "http://justice.gov.uk/core/courts/external/apiCourtsDefinitions.json",
          },
          {
            filename: "lib/schemas/global/apiJudicialResult.json",
            url: "http://justice.gov.uk/core/courts/external/apiJudicialResult.json",
          },
          {
            filename: "lib/schemas/global/apiDelegatedPowers.json",
            url: "http://justice.gov.uk/core/courts/external/apiDelegatedPowers.json",
          },
        ]

        refs.each do |ref|
          json_schema = JSON::Schema.new(
            JSON.parse(File.open(Rails.root.join(ref[:filename]).to_s).read),
            Addressable::URI.parse(ref[:url]),
          )
          JSON::Validator.add_schema(json_schema)
        end
      end
    end
  end
end
