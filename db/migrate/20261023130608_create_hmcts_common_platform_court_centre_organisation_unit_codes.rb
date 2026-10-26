class CreateHmctsCommonPlatformCourtCentreOrganisationUnitCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :hmcts_common_platform_court_centre_organisation_unit_codes do |t|
      t.uuid :court_centre_id
      t.string :code
      t.string :name

      t.timestamps

      t.index :court_centre_id, unique: true
    end
  end
end
