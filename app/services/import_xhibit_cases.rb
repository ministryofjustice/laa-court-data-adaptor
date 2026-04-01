require "csv"

class ImportXhibitCases < ApplicationService
  def initialize(file_path:)
    @file_path = file_path
  end

  def call
    results = { inserted: [], errors: [] }
    CSV.foreach(file_path, headers: true).with_index(2) do |row, line|
      xhibit_case = XhibitCase.create(row.to_h.transform_values(&:presence))
      if xhibit_case.errors.any?
        results[:errors] << { line:, case_urn: row["case_urn"], messages: xhibit_case.errors.full_messages }
      else
        results[:inserted] << { line:, case_urn: xhibit_case.case_urn }
      end
    end
    results
  end

private

  attr_reader :file_path
end
