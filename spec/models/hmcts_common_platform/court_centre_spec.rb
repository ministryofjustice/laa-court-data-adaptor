RSpec.describe HmctsCommonPlatform::CourtCentre, type: :model do
  let(:court_centre) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("court_centre/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:court_centre)
    end

    it "generates a JSON representation of the data" do
      expect(court_centre.to_json["id"]).to eq("14876ea1-5f7c-32ef-9fbd-aa0b63193550")
      expect(court_centre.to_json["name"]).to eq("Derby Justice Centre (aka Derby St Mary Adult)")
      expect(court_centre.to_json["welsh_name"]).to eq("Llys Ynadon Newton Aycliffe")
      expect(court_centre.to_json["room_id"]).to eq("2fc95ce0-79e5-33c6-901a-733c90905e59")
      expect(court_centre.to_json["room_name"]).to eq("Courtroom 08")
      expect(court_centre.to_json["welsh_room_name"]).to eq("Ystafell y llys 3")
      expect(court_centre.to_json["code"]).to eq("B30PI00")
      expect(court_centre.to_json["short_oucode"]).to eq("B30PI")
      expect(court_centre.to_json["oucode_l2_code"]).to eq("30")
      expect(court_centre.to_json["address"]).to be_present
      expect(court_centre.to_json["welsh_court_centre"]).to be true
    end

    it { expect(court_centre.id).to eq("14876ea1-5f7c-32ef-9fbd-aa0b63193550") }
    it { expect(court_centre.name).to eq("Derby Justice Centre (aka Derby St Mary Adult)") }
    it { expect(court_centre.to_json["welsh_name"]).to eq("Llys Ynadon Newton Aycliffe") }
    it { expect(court_centre.room_id).to eq("2fc95ce0-79e5-33c6-901a-733c90905e59") }
    it { expect(court_centre.room_name).to eq("Courtroom 08") }
    it { expect(court_centre.to_json["welsh_room_name"]).to eq("Ystafell y llys 3") }
    it { expect(court_centre.code).to eq("B30PI00") }
    it { expect(court_centre.short_oucode).to eq("B30PI") }
    it { expect(court_centre.oucode_l2_code).to eq("30") }
    it { expect(court_centre.address).to be_an(HmctsCommonPlatform::Address) }
    it { expect(court_centre.welsh_court_centre).to be true }
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
    it { expect(court_centre.code).to eq("B30PI00") }
    it { expect(court_centre.short_oucode).to eq("B30PI") }
    it { expect(court_centre.oucode_l2_code).to eq("30") }
  end
end
