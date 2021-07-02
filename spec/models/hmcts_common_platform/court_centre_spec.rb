RSpec.describe HmctsCommonPlatform::CourtCentre, type: :model do
  let(:court_centre) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("court_centre/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:court_centre)
    end

    it { expect(court_centre.id).to eq("14876ea1-5f7c-32ef-9fbd-aa0b63193550") }
    it { expect(court_centre.name).to eq("Derby Justice Centre (aka Derby St Mary Adult)") }
    it { expect(court_centre.room_id).to eq("2fc95ce0-79e5-33c6-901a-733c90905e59") }
    it { expect(court_centre.room_name).to eq("Courtroom 08") }
    it { expect(court_centre.code).to eq("A07AF00") }
    it { expect(court_centre.short_oucode).to eq("A07AF") }
    it { expect(court_centre.oucode_l2_code).to eq("7") }
  end

  context "with required fields only" do
    let(:data) { JSON.parse(file_fixture("court_centre/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:court_centre)
    end

    it { expect(court_centre.id).to eq("14876ea1-5f7c-32ef-9fbd-aa0b63193550") }
    it { expect(court_centre.name).to be_nil }
    it { expect(court_centre.room_id).to be_nil }
    it { expect(court_centre.room_name).to be_nil }
    it { expect(court_centre.code).to be_nil }
    it { expect(court_centre.short_oucode).to be_nil }
    it { expect(court_centre.oucode_l2_code).to be_nil }
  end
end
