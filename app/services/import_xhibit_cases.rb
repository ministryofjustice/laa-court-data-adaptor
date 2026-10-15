require "csv"

class ImportXhibitCases < ApplicationService
  PERMITTED_ATTRIBUTES = %w[
    case_urn
    xhibit_case_number
    court_name
    ou_code
    case_type
    case_sub_type
    mode_of_trial
    defendant_id
    defendant_first_name
    defendant_middle_name
    defendant_last_name
    defendant_date_of_birth
    defendant_arrest_summons_number
    committal_date
    sent_date
  ].freeze

  def initialize(file_path:)
    @file_path = file_path
  end

  def call
    results = { success_count: 0, errors: [] }
    CSV.foreach(file_path, headers: true).with_index(2) do |row, line_number|
      safe_params = row.to_h.transform_values(&:presence).slice(*PERMITTED_ATTRIBUTES)
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
end
