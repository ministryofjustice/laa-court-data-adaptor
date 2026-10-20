class AddCourtApplicationIdToLaaReferences < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    # Nullable with no default: metadata-only change, existing rows are not rewritten.
    # NULL means the reference links a prosecution case defendant; set means it links a court application subject.
    add_column :laa_references, :court_application_id, :uuid

    add_index :laa_references,
              :court_application_id,
              where: "linked AND court_application_id IS NOT NULL",
              algorithm: :concurrently
  end
end
