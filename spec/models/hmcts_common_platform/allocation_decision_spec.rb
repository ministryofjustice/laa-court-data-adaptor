RSpec.describe HmctsCommonPlatform::AllocationDecision, type: :model do
  let(:allocation_decision) { described_class.new(data) }

  context "when allocation_decision has all fields" do
    let(:data) { JSON.parse(file_fixture("allocation_decision.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:allocation_decision)
    end

    it "generates a JSON representation of the data" do
      expect(allocation_decision.to_json["originating_hearing_id"]).to eql("7084b980-d09d-40bc-b856-ea1fafd401bf")
      expect(allocation_decision.to_json["offence_id"]).to eql("e58b3a59-e5e5-4ec4-a478-2c846b9e6b6d")
      expect(allocation_decision.to_json["mot_reason_id"]).to eql("d47268e9-db2e-3aa3-827b-ba3afb7ff94a")
      expect(allocation_decision.to_json["mot_reason_description"]).to eql("Court directs trial by jury")
      expect(allocation_decision.to_json["mot_reason_code"]).to eql("5")
      expect(allocation_decision.to_json["date"]).to eql("2020-02-13")
      expect(allocation_decision.to_json["sequence_number"]).to be(20)
      expect(allocation_decision.to_json["court_indicated_sentence"]).to be_present
    end

    it { expect(allocation_decision.originating_hearing_id).to eql("7084b980-d09d-40bc-b856-ea1fafd401bf") }
    it { expect(allocation_decision.offence_id).to eql("e58b3a59-e5e5-4ec4-a478-2c846b9e6b6d") }
    it { expect(allocation_decision.mot_reason_id).to eql("d47268e9-db2e-3aa3-827b-ba3afb7ff94a") }
    it { expect(allocation_decision.mot_reason_description).to eql("Court directs trial by jury") }
    it { expect(allocation_decision.mot_reason_code).to eql("5") }
    it { expect(allocation_decision.date).to eql("2020-02-13") }
    it { expect(allocation_decision.sequence_number).to be(20) }
    it { expect(allocation_decision.court_indicated_sentence).to be_an(HmctsCommonPlatform::CourtIndicatedSentence) }
  end
end
