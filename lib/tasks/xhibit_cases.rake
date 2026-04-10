namespace :xhibit_cases do
  desc "Import XHIBIT cases from a CSV file. Example: rake xhibit_cases:import FILE_PATH=spec/fixtures/files/xhibit_cases_import.csv"

  task :import, [:file_path] => :environment do |_task, args|
    file_path = args[:file_path] || ENV["FILE_PATH"]

    abort "Usage: rake xhibit_cases:import FILE_PATH=path/to/xhibit_cases.csv" if file_path.blank?

    puts "[INFO - #{Time.zone.now}] Importing XHIBIT cases from #{file_path}..."

    results = ImportXhibitCases.call(file_path:)

    results[:errors].each do |row|
      puts "[ERROR - #{Time.zone.now}] Line #{row[:line]} (case_urn: #{row[:case_urn]}): #{row[:messages].join(', ')}"
    end

    puts "- - -"

    puts "[INFO  - #{Time.zone.now}] Import completed — #{results[:inserted].count} inserted, #{results[:errors].count} error(s)."
  end
end
