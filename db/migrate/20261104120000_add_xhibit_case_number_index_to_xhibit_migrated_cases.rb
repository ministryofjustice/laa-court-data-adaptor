class AddXhibitCaseNumberIndexToXhibitMigratedCases < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :xhibit_migrated_cases, :xhibit_case_number, algorithm: :concurrently
  end
end
