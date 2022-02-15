RSpec.describe HmctsCommonPlatform::CourtIndicatedSentence, type: :model do
  let(:court_indicated_sentence) { described_class.new(data) }

  context "when allocation_decision has all fields" do
    let(:data) { JSON.parse(file_fixture("court_indicated_sentence.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:court_indicated_sentence)
    end

    it "generates a JSON representation of the data" do
      expect(court_indicated_sentence.to_json["type_id"]).to eql("f7f76e0b-366b-4746-b0b0-4d8a46c6ad4e")
      expect(court_indicated_sentence.to_json["description"]).to eql("Aut laborum quia et.")
    end

    it { expect(court_indicated_sentence.type_id).to eql("f7f76e0b-366b-4746-b0b0-4d8a46c6ad4e") }
    it { expect(court_indicated_sentence.description).to eql("Aut laborum quia et.") }
  end
end
