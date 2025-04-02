class AddApplicationTypeToProsecutionCaseDefendantOffence < ActiveRecord::Migration[8.0]
  def change
    add_column :prosecution_case_defendant_offences, :application_type, :string, limit: 255
  end
end
