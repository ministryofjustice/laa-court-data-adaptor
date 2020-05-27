# frozen_string_literal: true

class ProsecutionCaseSerializer
  include FastJsonapi::ObjectSerializer
  set_type :prosecution_cases

  attributes :prosecution_case_reference

  has_many :defendants, record_type: :defendants
  has_many :hearing_summaries, record_type: :hearing_summaries
  has_many :hearings, record_type: :hearings, if: proc { |_record, params| params[:inclusions].try(:include?, 'hearings') }
end
