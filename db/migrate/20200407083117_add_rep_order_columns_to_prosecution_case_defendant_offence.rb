# frozen_string_literal: true

class AddRepOrderColumnsToProsecutionCaseDefendantOffence < ActiveRecord::Migration[6.0]
  def change
    change_table :prosecution_case_defendant_offences, bulk: true do |t|
      t.datetime :status_date
      t.datetime :effective_start_date
      t.datetime :effective_end_date
      t.json :defence_organisation
    end
  end
end
