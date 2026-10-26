RSpec.describe HmctsCommonPlatform::CourtCentre::OrganisationUnitCode, type: :model do
  subject(:organisation_unit_code) { build(:court_centre_organisation_unit_code) }

  it "has a court centre ID" do
    expect(organisation_unit_code.court_centre_id).to be_present
  end

  it "has a code" do
    expect(organisation_unit_code.code).to eq("B30PI00")
  end

  it "can be persisted" do
    expect { create(:court_centre_organisation_unit_code) }
      .to change(described_class, :count).by(1)
  end

  it "validates uniqueness of court centre ID" do
    organisation_unit_code.save!
    organisation_unit_code_2 = build(:court_centre_organisation_unit_code, court_centre_id: organisation_unit_code.court_centre_id)
    expect(organisation_unit_code_2).not_to be_valid
  end
end
