# frozen_string_literal: true

class CreateProsecutionCase < ActiveRecord::Migration[6.0]
  def change
    create_table :prosecution_cases, id: :uuid do |t|
      t.jsonb :body, null: false

      t.timestamps
    end
  end
end
