class CreateCourtApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :court_applications, id: :uuid do |t|
      t.jsonb :body
      t.uuid :subject_id

      t.timestamps
    end

    remove_column :prosecution_case_defendant_offences, :application_type, :string
  end
end
