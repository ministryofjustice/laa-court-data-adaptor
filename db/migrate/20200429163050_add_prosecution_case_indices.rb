# frozen_string_literal: true

class AddProsecutionCaseIndices < ActiveRecord::Migration[6.0]
  def change
    add_index :prosecution_case_defendant_offences, :prosecution_case_id, name: "index_case_defendant_offences_on_prosecution_case"
    add_index :prosecution_case_defendant_offences, :defendant_id
    add_index :prosecution_case_defendant_offences, :offence_id
    add_foreign_key :prosecution_case_defendant_offences, :prosecution_cases
  end
end
