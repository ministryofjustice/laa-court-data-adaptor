require "csv"

class ImportXhibitCases < ApplicationService
  def initialize(file_path:)
    @file_path = file_path
  end

  def call
    results = { success_count: 0, errors: [] }
    CSV.foreach(file_path, headers: true).with_index(2) do |row, line_number|
      safe_params = row.to_h.transform_values(&:presence).slice(*permitted_attributes)
      xhibit_case = XhibitMigratedCase.create(safe_params)
      if xhibit_case.persisted?
        results[:success_count] += 1
      else
        results[:errors] << { line_number:, case_urn: row["case_urn"], row: row.to_h, messages: xhibit_case.errors.full_messages }
      end
    end
    results
  end

private

  attr_reader :file_path

  def permitted_attributes
    XhibitMigratedCase.column_names - %w[id]
  end
end
