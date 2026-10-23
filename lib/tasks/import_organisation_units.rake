namespace :import do
  desc "Import organisation units"
  task organisation_units: :environment do
    rows = CSV.read(Rails.root.join("lib/organisation_unit.csv"), headers: true).map do |row|
      { court_centre_id: row["id"], code: row["oucode"], name: row["oucode_l3_name"] }
    end
    HmctsCommonPlatform::CourtCentre::OrganisationUnitCode.upsert_all(rows, unique_by: :court_centre_id)
  end
end
