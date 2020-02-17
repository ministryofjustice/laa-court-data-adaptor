# frozen_string_literal: true

class AddColumnsToProsecutionCaseDefendantOffences < ActiveRecord::Migration[6.0]
  def change
    add_column :prosecution_case_defendant_offences, :maat_reference, :string
    add_column :prosecution_case_defendant_offences, :dummy_maat_reference, :boolean
    add_column :prosecution_case_defendant_offences, :response_status, :integer
    add_column :prosecution_case_defendant_offences, :response_body, :json
    add_column :prosecution_case_defendant_offences, :user_id, :string
  end
end
