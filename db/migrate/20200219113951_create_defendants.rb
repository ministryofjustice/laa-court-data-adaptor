# frozen_string_literal: true

class CreateDefendants < ActiveRecord::Migration[6.0]
  def change
    create_table :defendants, id: :uuid do |t|
      t.jsonb :body, null: false

      t.timestamps
    end
  end
end
