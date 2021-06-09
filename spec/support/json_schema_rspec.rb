RSpec.configure do |config|
  config.include JSON::SchemaMatchers

  schema_path = "lib/schemas"

  config.json_schemas[:court_application] = "#{schema_path}/global/apiCourtApplication.json"
  config.json_schemas[:court_application_party] = "#{schema_path}/global/apiCourtApplicationParty.json"
  config.json_schemas[:court_application_type] = "#{schema_path}/global/apiCourtApplicationType.json"
  config.json_schemas[:court_centre] = "#{schema_path}/global/apiCourtCentre.json"
  config.json_schemas[:defendant] = "#{schema_path}/global/apiDefendant.json"
  config.json_schemas[:defendant_summary] = "#{schema_path}/global/search/apiDefendantSummary.json"
  config.json_schemas[:delegated_powers] = "#{schema_path}/global/apiDelegatedPowers.json"
  config.json_schemas[:hearing] = "#{schema_path}/global/apiHearing.json"
  config.json_schemas[:hearing_day] = "#{schema_path}/global/apiHearingDay.json"
  config.json_schemas[:hearing_summary] = "#{schema_path}/global/search/apiHearingSummary.json"
  config.json_schemas[:judicial_result] = "#{schema_path}/global/apiJudicialResult.json"
  config.json_schemas[:laa_reference] = "#{schema_path}/global/apiLaaReference.json"
  config.json_schemas[:lesser_or_alternative_offence] = "#{schema_path}/global/apiLesserOrAlternativeOffence.json"
  config.json_schemas[:offence] = "#{schema_path}/global/apiOffence.json"
  config.json_schemas[:offence_summary] = "#{schema_path}/global/search/apiOffenceSummary.json"
  config.json_schemas[:person_defendant] = "#{schema_path}/global/apiPersonDefendant.json"
  config.json_schemas[:plea] = "#{schema_path}/global/apiPlea.json"
  config.json_schemas[:prosecution_case_summary] = "#{schema_path}/global/search/apiProsecutionCaseSummary.json"
  config.json_schemas[:verdict] = "#{schema_path}/global/apiVerdict.json"
end
