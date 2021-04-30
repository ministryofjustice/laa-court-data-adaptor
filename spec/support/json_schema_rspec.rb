RSpec.configure do |config|
  config.include JSON::SchemaMatchers

  schema_path = "lib/schemas"

  config.json_schemas[:judicial_result] = "#{schema_path}/global/apiJudicialResult.json"
end
