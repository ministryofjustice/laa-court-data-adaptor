class CreateCourtApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :court_applications, id: :uuid do |t|
      t.jsonb :body
      t.uuid :subject_id

      t.timestamps
    end

    create_table :court_application_offences, id: :uuid do |t|
      t.references :court_application, foreign_key: true, type: :uuid
      t.uuid :offence_id

      t.timestamps
    end

    remove_column :prosecution_case_defendant_offences, :application_type, :string
  end
end
