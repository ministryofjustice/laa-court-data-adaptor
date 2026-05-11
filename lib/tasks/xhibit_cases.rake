require "csv"

namespace :xhibit_cases do
  desc "Import XHIBIT cases from a CSV file. Example: rake xhibit_cases:import FILE_PATH=spec/fixtures/files/xhibit_cases_import.csv"

  task :import, [:file_path] => :environment do |_task, args|
    file_path = args[:file_path] || ENV["FILE_PATH"]

    abort "Usage: rake xhibit_cases:import FILE_PATH=path/to/xhibit_cases.csv" if file_path.blank?
    abort "File not found: #{file_path}" unless File.exist?(file_path)

    puts "[INFO - #{Time.zone.now}] Importing XHIBIT cases from #{file_path}..."

    results = ImportXhibitCases.call(file_path:)

    results[:errors].each do |row|
      puts "[ERROR - #{Time.zone.now}] Line #{row[:line_number]}: #{row[:messages].join(', ')}"
    end

    errors_file = "/tmp/import-errors.csv"
    input_headers = CSV.open(file_path, headers: true) { |csv| csv.first&.headers } || []

    CSV.open(errors_file, "w") do |csv|
      csv << input_headers + %w[errors]

      results[:errors].each do |error|
        csv << error[:row].values_at(*input_headers) + [error[:messages].join(" | ")]
      end
    end

    puts "- - -"

    puts "[INFO  - #{Time.zone.now}] Import completed — #{results[:success_count]} inserted, #{results[:errors].count} error(s)."
    puts "[INFO  - #{Time.zone.now}] Error details written to #{errors_file}"
  end
end
