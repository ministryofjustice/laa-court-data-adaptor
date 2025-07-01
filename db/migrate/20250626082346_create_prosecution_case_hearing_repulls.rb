class CreateProsecutionCaseHearingRepulls < ActiveRecord::Migration[8.0]
  def change
    create_table :hearing_repull_batches, id: :uuid, &:timestamps

    create_table :prosecution_case_hearing_repulls, id: :uuid do |t|
      t.references :hearing_repull_batch, foreign_key: true, type: :uuid
      t.references :prosecution_case, foreign_key: true, type: :uuid
      t.string :status, default: "pending"
      t.string :maat_ids
      t.string :urn

      t.timestamps
    end
  end
end
