# frozen_string_literal: true

class AddColumnsToProsecutionCaseDefendantOffences < ActiveRecord::Migration[6.0]
  def change
    add_column :prosecution_case_defendant_offences, :maat_reference, :string
    add_column :prosecution_case_defendant_offences, :dummy_maat_reference, :boolean, default: false, null: false
    add_column :prosecution_case_defendant_offences, :response_status, :integer
    add_column :prosecution_case_defendant_offences, :response_body, :json
  end
end
