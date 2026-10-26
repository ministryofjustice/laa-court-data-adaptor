class AddLlandrindodWellsJusticeCentre < ActiveRecord::Migration[8.1]
  def up
    HmctsCommonPlatform::CourtCentre::OrganisationUnitCode.create!(
      court_centre_id: "1efd6276-4160-3ed0-ba67-1b32550c8d10",
      code: "B63LW00",
      name: "Llandrindod Wells Justice Centre",
    )
  end

  def down
    HmctsCommonPlatform::CourtCentre::OrganisationUnitCode.find_by(
      court_centre_id: "1efd6276-4160-3ed0-ba67-1b32550c8d10",
    )&.destroy
  end
end
