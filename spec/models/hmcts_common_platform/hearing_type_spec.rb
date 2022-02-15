RSpec.describe HmctsCommonPlatform::HearingType, type: :model do
  let(:hearing_type) { described_class.new(data) }

  context "when verdict has all fields" do
    let(:data) { JSON.parse(file_fixture("hearing_type.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:hearing_type)
    end

    it "generates a JSON representation of the data" do
      expect(hearing_type.to_json["id"]).to eq("4a0e892d-c0c5-3c51-95b8-704d8c781776")
      expect(hearing_type.to_json["description"]).to eq("Description")
      expect(hearing_type.to_json["welsh_description"]).to eq("Welsh description")
    end

    it { expect(hearing_type.id).to eq("4a0e892d-c0c5-3c51-95b8-704d8c781776") }
    it { expect(hearing_type.description).to eq("Description") }
    it { expect(hearing_type.welsh_description).to eq("Welsh description") }
  end
end
