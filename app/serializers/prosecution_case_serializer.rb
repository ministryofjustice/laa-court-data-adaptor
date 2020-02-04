# frozen_string_literal: true

class ProsecutionCaseSerializer
  include FastJsonapi::ObjectSerializer
  set_type :prosecution_cases

  attributes :prosecution_case_reference, :date_of_birth, :national_insurance_number

  attribute :first_name, &:defendant_first_name
  attribute :last_name, &:defendant_last_name
end
