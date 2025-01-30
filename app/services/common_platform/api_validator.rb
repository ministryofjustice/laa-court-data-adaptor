require 'json-schema'

class ApiValidator
  SCHEMA_PATH = Rails.root.join('config/schemas/external_service_schema.json')

  def self.validate(json_response)
    JSON::Validator.validate!(SCHEMA_PATH.to_s, json_response)
  rescue JSON::Schema::ValidationError => e
    Rails.logger.error("JSON Schema Validation Error: #{e.message}")
    false
  end
end
