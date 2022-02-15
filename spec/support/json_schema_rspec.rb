RSpec.configure do |config|
  config.include JSON::SchemaMatchers

  schema_path = "lib/schemas"

  config.json_schemas[:address] = "#{schema_path}/global/apiAddress.json"
  config.json_schemas[:contact_details] = "#{schema_path}/global/apiContactNumber.json"
  config.json_schemas[:court_application] = "#{schema_path}/global/apiCourtApplication.json"
  config.json_schemas[:court_application_party] = "#{schema_path}/global/apiCourtApplicationParty.json"
  config.json_schemas[:court_application_type] = "#{schema_path}/global/apiCourtApplicationType.json"
  config.json_schemas[:court_centre] = "#{schema_path}/global/apiCourtCentre.json"
  config.json_schemas[:cracked_ineffective_trial] = "#{schema_path}/global/apiCrackedIneffectiveTrial.json"
  config.json_schemas[:defendant] = "#{schema_path}/global/apiDefendant.json"
  config.json_schemas[:defendant_case] = "#{schema_path}/global/apiDefendantCase.json"
  config.json_schemas[:defence_counsel] = "#{schema_path}/global/apiDefenceCounsel.json"
  config.json_schemas[:defendant_summary] = "#{schema_path}/global/search/apiDefendantSummary.json"
  config.json_schemas[:delegated_powers] = "#{schema_path}/global/apiDelegatedPowers.json"
  config.json_schemas[:hearing] = "#{schema_path}/global/apiHearing.json"
  config.json_schemas[:hearing_day] = "#{schema_path}/global/apiHearingDay.json"
  config.json_schemas[:hearing_resulted] = "#{schema_path}/api/hearing-resulted.json"
  config.json_schemas[:hearing_summary] = "#{schema_path}/global/search/apiHearingSummary.json"
  config.json_schemas[:hearing_type] = "#{schema_path}/global/apiHearingType.json"
  config.json_schemas[:judicial_result] = "#{schema_path}/global/apiJudicialResult.json"
  config.json_schemas[:judicial_role] = "#{schema_path}/global/apiJudicialRole.json"
  config.json_schemas[:laa_reference] = "#{schema_path}/global/apiLaaReference.json"
  config.json_schemas[:lesser_or_alternative_offence] = "#{schema_path}/global/apiLesserOrAlternativeOffence.json"
  config.json_schemas[:offence] = "#{schema_path}/global/apiOffence.json"
  config.json_schemas[:offence_summary] = "#{schema_path}/global/search/apiOffenceSummary.json"
  config.json_schemas[:person_defendant] = "#{schema_path}/global/apiPersonDefendant.json"
  config.json_schemas[:person] = "#{schema_path}/global/apiPerson.json"
  config.json_schemas[:plea] = "#{schema_path}/global/apiPlea.json"
  config.json_schemas[:prosecution_case] = "#{schema_path}/global/apiProsecutionCase.json"
  config.json_schemas[:prosecution_case_summary] = "#{schema_path}/global/search/apiProsecutionCaseSummary.json"
  config.json_schemas[:prosecution_conclusion] = "#{schema_path}/api/progression.api.prosecutionConcludedRequest.json"
  config.json_schemas[:prosecution_counsel] = "#{schema_path}/global/apiProsecutionCounsel.json"
  config.json_schemas[:representation_order] = "#{schema_path}/global/apiRepresentationOrder.json"
  config.json_schemas[:search_prosecution_case_response] = "#{schema_path}/api/search-prosecutionCaseResponse.json"
  config.json_schemas[:verdict] = "#{schema_path}/global/apiVerdict.json"
  config.json_schemas[:verdict_type] = "#{schema_path}/global/apiVerdictType.json"
end
