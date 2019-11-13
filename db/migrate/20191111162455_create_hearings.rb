# frozen_string_literal: true

class CreateHearings < ActiveRecord::Migration[6.0]
  def change
    create_table :hearings, id: :uuid do |t|
      t.jsonb :body, null: false

      t.timestamps
    end
  end
end
