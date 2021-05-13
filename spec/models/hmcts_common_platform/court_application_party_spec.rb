RSpec.describe HmctsCommonPlatform::CourtApplicationParty, type: :model do
  let(:court_application_party) { described_class.new(data) }

  context "with required fields" do
    let(:data) { JSON.parse(file_fixture("court_application_party/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:court_application_party)
    end

    it "has an id" do
      expect(court_application_party.id).to eql("4f59e8d5-53d5-4175-b9b3-d46363671d03")
    end

    it "has no synonym" do
      expect(court_application_party.synonym).to be_nil
    end

    it "has a summons_required flag" do
      expect(court_application_party.summons_required).to be false
    end

    it "has a notification_required flag" do
      expect(court_application_party.notification_required).to be true
    end
  end

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("court_application_party/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:court_application_party)
    end

    it "has an id" do
      expect(court_application_party.id).to eql("4f59e8d5-53d5-4175-b9b3-d46363671d03")
    end

    it "has a synonym" do
      expect(court_application_party.synonym).to eql("suspect")
    end

    it "has a summons_required flag" do
      expect(court_application_party.summons_required).to be false
    end

    it "has a notification_required flag" do
      expect(court_application_party.notification_required).to be true
    end
  end
end
