# frozen_string_literal: true

class CreateHearingEventRecordings < ActiveRecord::Migration[6.0]
  def change
    create_table :hearing_event_recordings, id: :uuid do |t|
      t.references :hearing, type: :uuid
      t.date :hearing_date
      t.jsonb :body, null: false

      t.timestamps
    end
    remove_column :hearings, :events, :jsonb
  end
end
