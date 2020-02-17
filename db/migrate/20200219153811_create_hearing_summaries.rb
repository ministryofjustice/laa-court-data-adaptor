# frozen_string_literal: true

class CreateHearingSummaries < ActiveRecord::Migration[6.0]
  def change
    create_table :hearing_summaries, id: :uuid do |t|
      t.jsonb :body, null: false

      t.timestamps
    end
  end
end
