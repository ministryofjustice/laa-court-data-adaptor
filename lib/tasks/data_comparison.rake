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

def compare_defendant_data(case_urn, defendant_id, v1_defendant_json, v2_defendant_json)
  results = []
  # Really we should iterate of the offences and pleas are there could be multiple - also we need to do a "safe"
  # JSON traversal that allows to missing properties etc.
  v1_plea = v1_defendant_json.fetch("included").first.fetch("attributes").fetch("pleas").first.fetch("code")
  v2_plea = v2_defendant_json.fetch("offence_summaries").first.fetch("pleas").first.fetch("value")
  results.append [case_urn, defendant_id, "PLEA", v1_plea, v2_plea, v1_plea == v2_plea]
end

def generate_csv_results(test_results_array)
  CSV.generate(headers: true) do |csv|
    csv << ["CASE URN", "DEFENDANT ID", "PROPERTY", "V1-VALUE", "V2-VALUE", "MATCH"]
    test_results_array.each do |result_array|
      csv << [result_array[0], result_array[1], result_array[2], result_array[3], result_array[4], result_array[5]]
    end
  end
end
