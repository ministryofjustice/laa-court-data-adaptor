# frozen_string_literal: true

class CreateLaaReferences < ActiveRecord::Migration[6.0]
  def change
    create_table :laa_references, id: :uuid do |t|
      t.uuid :defendant_id, null: false, index: true
      t.string :maat_reference, null: false, index: { unique: true, where: "linked" }
      t.boolean :dummy_maat_reference, default: false, null: false
      t.boolean :linked, default: true, null: false

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          INSERT INTO laa_references (maat_reference, defendant_id, dummy_maat_reference, linked, created_at, updated_at)
          SELECT DISTINCT ON (maat_reference) maat_reference, defendant_id, dummy_maat_reference, true, created_at, updated_at
          FROM prosecution_case_defendant_offences
          WHERE maat_reference IS NOT NULL
        SQL
      end
    end

    rename_column :prosecution_case_defendant_offences, :maat_reference, :deprecated_maat_reference
    rename_column :prosecution_case_defendant_offences, :dummy_maat_reference, :deprecated_dummy_maat_reference
  end
end
