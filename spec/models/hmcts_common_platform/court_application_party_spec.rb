RSpec.describe HmctsCommonPlatform::CourtApplicationParty, type: :model do
  let(:court_application_party) { described_class.new(data) }

  context "with required fields" do
    let(:data) { JSON.parse(file_fixture("court_application_party/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:court_application_party)
    end

    it { expect(court_application_party.id).to eql("4f59e8d5-53d5-4175-b9b3-d46363671d03") }
    it { expect(court_application_party.synonym).to be_nil }
    it { expect(court_application_party.summons_required).to be false }
    it { expect(court_application_party.notification_required).to be true }
  end

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("court_application_party/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:court_application_party)
    end

    it "generates a JSON representation of the data" do
      expect(court_application_party.to_json["id"]).to eql("4f59e8d5-53d5-4175-b9b3-d46363671d03")
      expect(court_application_party.to_json["synonym"]).to eql("suspect")
      expect(court_application_party.to_json["summons_required"]).to be false
      expect(court_application_party.to_json["notification_required"]).to be true
    end

    it { expect(data).to match_json_schema(:court_application_party) }
    it { expect(court_application_party.id).to eql("4f59e8d5-53d5-4175-b9b3-d46363671d03") }
    it { expect(court_application_party.synonym).to eql("suspect") }
    it { expect(court_application_party.summons_required).to be false }
    it { expect(court_application_party.notification_required).to be true }
  end
end
