require "rails_helper"

RSpec.describe "import:organisation_units task" do
  let(:csv_path) { Rails.root.join("lib/organisation_unit.csv") }

  let(:rows) do
    [
      CSV::Row.new(%w[id oucode oucode_l3_name], [SecureRandom.uuid, "B30PI00", "Derby Justice Centre"]),
      CSV::Row.new(%w[id oucode oucode_l3_name], [SecureRandom.uuid, "B01LY00", "London Justice Centre"]),
    ]
  end

  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?

    allow(CSV).to receive(:read).and_return(rows)
  end

  after { Rake::Task["import:organisation_units"].reenable }

  it "upserts the organisation unit codes by court centre ID" do
    expect { Rake::Task["import:organisation_units"].execute }.to change(HmctsCommonPlatform::CourtCentre::OrganisationUnitCode, :count).by(2)

    expect(HmctsCommonPlatform::CourtCentre::OrganisationUnitCode.find_by(court_centre_id: rows[0][:id])&.code).to eq(rows[0][:oucode])
    expect(HmctsCommonPlatform::CourtCentre::OrganisationUnitCode.find_by(court_centre_id: rows[0][:id])&.name).to eq(rows[0][:oucode_l3_name])
    expect(HmctsCommonPlatform::CourtCentre::OrganisationUnitCode.find_by(court_centre_id: rows[1][:id])&.code).to eq(rows[1][:oucode])
    expect(HmctsCommonPlatform::CourtCentre::OrganisationUnitCode.find_by(court_centre_id: rows[1][:id])&.name).to eq(rows[1][:oucode_l3_name])
  end

  it "does not create duplicates when run multiple times" do
    Rake::Task["import:organisation_units"].execute

    expect { Rake::Task["import:organisation_units"].execute }.not_to change(HmctsCommonPlatform::CourtCentre::OrganisationUnitCode, :count)
  end
end
