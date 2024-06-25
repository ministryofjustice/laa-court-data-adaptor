require "csv"
require "json"

namespace :data_comparison do
  desc "Compares key data from the v1 and v2 defendant endpoints to check for differences. It will compare
        all defendants on the provided case urns.
        Example: rake data_comparison:defendant_data[urn1-urn2-urn3]"
  task :defendant_data, [:case_list] => [:environment] do |_task, args|
    include Api::Internal::V1
    case_urns = args[:case_list].split("-")

    test_results = []
    case_urns.each do |case_urn|
      current_case_data = get_prosecution_case(case_urn)

      get_case_defendants(current_case_data).each do |defendant|
        puts "[INFO - #{Time.zone.now}] retrieving defendant response data for defendant id #{defendant}"
        v1_defendant_json = get_v1_defendant_json(defendant)
        v2_defendant_json = get_v2_defendant_json(current_case_data, defendant)

        puts "[INFO - #{Time.zone.now}] Comparing JSON responses for defendant id #{defendant}"
        test_results.concat compare_defendant_data(case_urn, defendant, v1_defendant_json, v2_defendant_json)
      rescue StandardError => e
        puts "[ERROR - #{Time.zone.now}] Error in process at CASE ID: #{case_urn} and Defendant ID: #{defendant}"
        puts "[ERROR - #{Time.zone.now}] #{e}"
      end
    end
    csv_data = generate_csv_results(test_results)
    puts "----------------------------"
    puts "-----Generated CSV data-----"
    puts csv_data
  end
end

def get_case_defendants(current_case_data)
  puts "[INFO - #{Time.zone.now}] Getting defendant ids for Case: #{current_case_data.prosecution_case_reference}."

  current_case_data
    .defendant_summaries
    .map(&:defendant_id)
end

def get_prosecution_case(case_urn)
  puts "[INFO - #{Time.zone.now}] Getting prosecution case: #{case_urn}."
  case_summaries = CommonPlatform::Api::SearchProsecutionCase.call(prosecution_case_reference: case_urn)
  HmctsCommonPlatform::ProsecutionCaseSummary.new(case_summaries.first.body)
end

def get_v1_defendant_json(defendant_id)
  puts "[INFO - #{Time.zone.now}] Getting defendant id: #{defendant_id} using V1."
  defendant = CommonPlatform::Api::DefendantFinder.call(defendant_id: defendant_id)
  JSON.parse(DefendantSerializer.new(defendant, include: %w[offences]).to_json)
end

def get_v2_defendant_json(current_case_data, defendant_id)
  puts "[INFO - #{Time.zone.now}] Getting defendant id: #{defendant_id} using V2."
  defendant = current_case_data
                .defendant_summaries
                .find { |ds| ds.defendant_id.eql?(defendant_id) }
  defendant.to_json
end

def compare_maat_reference(case_urn, defendant_id, v1_defendant_json, v2_offences)
  results = []

  v1_maat_ref = v1_defendant_json.fetch("maat_reference", nil)
  v2_maat_refs = v2_offences.map { |offence| offence.fetch("laa_reference", nil)&.fetch("reference") }.uniq

  results.append [case_urn, defendant_id, "MAAT REFERENCE", v1_maat_ref, "[#{v2_maat_refs.join("-")}]", [v1_maat_ref] == v2_maat_refs]
end

def get_v1_offences(v1_defendant_json)
  v1_defendant_json.fetch("included", []).select { |item| item.fetch("type", nil) == "offences" }
end

def get_v2_offences(v2_defendant_json)
  v2_defendant_json.fetch("offences_summaries")
end

def compare_mode_of_trial(case_urn, defendant_id, v1_offences, v2_offences)
  compare_offence_data(case_urn, defendant_id, v1_offences, v2_offences, "MODE OF TRIAL", "mode_of_trial", "mode_of_trial")
end

def compare_offences(case_urn, defendant_id, v1_offences, v2_offences)
  results = []
  results.append [case_urn, defendant_id, "OFFENCE COUNT", v1_offences.count, v2_offences.count, v1_offences.count == v2_offences.count]
end

def compare_offence_dates(case_urn, defendant_id, v1_offences, v2_offences)
  compare_offence_data(case_urn, defendant_id, v1_offences, v2_offences, "OFFENCE DATE", "start_date", "start_date")
end

def compare_offence_data(case_urn, defendant_id, v1_offences, v2_offences, property_name, v1_lookup, v2_lookup)
  results = []

  v1_offences.each do |v1_offence|
    v2_offence = v2_offences.select { |item| item.fetch("id", nil) == v1_offence.fetch("id") }.first
    v2_offence_data = "#{v2_offence["id"]}-#{v2_offence.fetch(v2_lookup, nil)}"
    v1_offence_data = "#{v1_offence["id"]}-#{v1_offence.fetch(v1_lookup, nil)}"
    results.append [case_urn, defendant_id, property_name, v1_offence_data, v2_offence_data, v1_offence_data == v2_offence_data]
  end
end

def compare_pleas(case_urn, defendant_id, v1_offences, v2_offences)
  results = []

  v1_offences.each do |v1_offence|
    v2_offence = v2_offences.select { |item| item.fetch("id", nil) == v1_offence.fetch("id") }.first
    v1_pleas = v2_offence.fetch("pleas", ["NO_PLEA"]).map { |item| item["value"] }
    v2_pleas = v2_offence.fetch("pleas", ["NO_PLEA"]).map { |item| item["code"] }

    v1_offence_pleas = [v1_offence.fetch("id")].concat v1_pleas
    v2_offence_pleas = [v2_offence.fetch("id")].concat v2_pleas

    results.append [case_urn, defendant_id, "PLEAS", "[#{v1_offence_pleas.join("-")}]", "[#{v2_offence_pleas.join("-")}]", v1_pleas == v2_pleas]
  end
end

def compare_verdicts(case_urn, defendant_id, v1_offences, v2_offences)
  results = []

  v1_offences.each do |v1_offence|
    v2_offence = v2_offences.select { |item| item.fetch("id", nil) == v1_offence.fetch("id") }.first
    v1_verdict = v2_offence.fetch("verdict", ["NO_VERDICT"]).map { |item| item.fetch("verdict_type", nil)&.fetch("category_type", nil) }
    v2_verdict = v2_offence.fetch("verdict", ["NO_VERDICT"]).map { |item| item.fetch("type", nil)&.fetch("category_type", nil) }

    v1_offence_pleas = "#{v1_offence.fetch("id")}-#{v1_verdict}"
    v2_offence_pleas = "#{v2_offence.fetch("id")}-#{v2_verdict}"

    results.append [case_urn, defendant_id, "VERDICT", v1_offence_pleas, v2_offence_pleas, v1_verdict == v2_verdict]
  end
end

def compare_defendant_data(case_urn, defendant_id, v1_defendant_json, v2_defendant_json)
  results = []

  v1_offences = get_v1_offences(v1_defendant_json)
  v2_offences = get_v2_offences(v2_defendant_json)

  results.concat compare_offences(case_urn, defendant_id, v1_offences, v2_offences)
  results.concat compare_maat_reference(case_urn, defendant_id, v1_defendant_json, v2_offences)
  results.concat compare_mode_of_trial(case_urn, defendant_id, v1_offences, v2_offences)
  results.concat compare_offence_dates(case_urn, defendant_id, v1_offences, v2_offences)
  results.concat compare_pleas(case_urn, defendant_id, v1_offences, v2_offences)
  results.concat compare_verdicts(case_urn, defendant_id, v1_offences, v2_offences)

end

def generate_csv_results(test_results_array)
  CSV.generate(headers: true) do |csv|
    csv << ["CASE URN", "DEFENDANT ID", "PROPERTY", "V1-VALUE", "V2-VALUE", "MATCH"]
    test_results_array.each do |result_array|
      csv << [result_array[0], result_array[1], result_array[2], result_array[3], result_array[4], result_array[5]]
    end
  end
end
