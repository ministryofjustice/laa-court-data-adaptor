class CreateXhibitCases < ActiveRecord::Migration[8.0]
  def change
    create_table :xhibit_cases, id: :uuid do |t|
      t.string :case_urn                        # Unique case identifier on Common Platform
      t.string :xhibit_case_number              # Legacy XHIBIT case ID, e.g. T20254007
      t.string :court_name
      t.string :ou_code                         # organisation unit code for a court
      t.string :case_type                       # T (trial), S (Sentence/Breach), A (Appeal)
      t.string :case_sub_type
      t.string :mode_of_trial
      t.string :defendant_id                    # CP defendant identifier, mostly for troubleshooting
      t.string :defendant_first_name
      t.string :defendant_middle_name
      t.string :defendant_last_name
      t.date   :defendant_date_of_birth
      t.string :defendant_arrest_summons_number # The ASN
      t.date   :committal_date                  # Date case was committed to Crown Court
      t.date   :sent_date                       # Held on XHIBIT. NOTE: Majority of new cases will have the sent date rather than the committal date.

      t.timestamps
    end
  end
end
