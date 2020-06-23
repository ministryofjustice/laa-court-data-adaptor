# frozen_string_literal: true

class AddColumnsToProsecutionCaseDefendantOffences < ActiveRecord::Migration[6.0]
  def change
    change_table :prosecution_case_defendant_offences, bulk: true do |t|
      t.string :maat_reference
      t.boolean :dummy_maat_reference, default: false, null: false
      t.string :rep_order_status
      t.integer :response_status
      t.json :response_body
    end
  end
end
