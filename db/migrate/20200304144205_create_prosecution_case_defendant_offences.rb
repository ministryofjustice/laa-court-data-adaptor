# frozen_string_literal: true

class CreateProsecutionCaseDefendantOffences < ActiveRecord::Migration[6.0]
  def change
    create_table :prosecution_case_defendant_offences, id: :uuid do |t|
      t.uuid :prosecution_case_id,    null: false
      t.uuid :defendant_id,           null: false
      t.uuid :offence_id,             null: false

      t.timestamps
    end
  end
end
