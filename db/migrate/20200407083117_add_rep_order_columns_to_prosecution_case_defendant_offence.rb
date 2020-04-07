# frozen_string_literal: true

class AddRepOrderColumnsToProsecutionCaseDefendantOffence < ActiveRecord::Migration[6.0]
  def change
    add_column :prosecution_case_defendant_offences, :status_date, :datetime
    add_column :prosecution_case_defendant_offences, :effective_start_date, :datetime
    add_column :prosecution_case_defendant_offences, :effective_end_date, :datetime
    add_column :prosecution_case_defendant_offences, :defence_organisation, :json
  end
end
