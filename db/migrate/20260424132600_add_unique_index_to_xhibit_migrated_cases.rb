class AddUniqueIndexToXhibitMigratedCases < ActiveRecord::Migration[8.0]
  def up
    execute(<<~SQL)
      DELETE FROM xhibit_migrated_cases
      WHERE id NOT IN (
        SELECT DISTINCT ON (case_urn, defendant_first_name, defendant_last_name) id
        FROM xhibit_migrated_cases
        ORDER BY case_urn, defendant_first_name, defendant_last_name, created_at ASC
      )
    SQL

    add_index :xhibit_migrated_cases,
              %i[case_urn defendant_first_name defendant_last_name],
              unique: true,
              name: "idx_xhibit_migrated_cases_unique_case_defendant"
  end

  def down
    remove_index :xhibit_migrated_cases,
                 name: "idx_xhibit_migrated_cases_unique_case_defendant"
  end
end
