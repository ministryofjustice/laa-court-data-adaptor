class RenameXhibitCasesToXhibitMigratedCases < ActiveRecord::Migration[8.0]
  def change
    rename_table :xhibit_cases, :xhibit_migrated_cases

    change_table :xhibit_migrated_cases, bulk: true do |t|
      t.string :status
      t.string :maat_id
      t.datetime :linked_at
      t.string :linked_by
      t.jsonb :process_errors
    end
  end
end
