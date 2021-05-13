RSpec.configure do |config|
  config.include JSON::SchemaMatchers

  schema_path = "lib/schemas"

  config.json_schemas[:judicial_result] = "#{schema_path}/global/apiJudicialResult.json"
  config.json_schemas[:court_application_party] = "#{schema_path}/global/apiCourtApplicationParty.json"
  config.json_schemas[:court_application_type] = "#{schema_path}/global/apiCourtApplicationType.json"
end
