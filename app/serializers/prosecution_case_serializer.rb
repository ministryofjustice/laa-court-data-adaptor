# frozen_string_literal: true

class ProsecutionCaseSerializer
  include FastJsonapi::ObjectSerializer
  set_type :prosecution_cases

  attributes :prosecution_case_reference

  has_many :defendants, record_type: :defendants
end
