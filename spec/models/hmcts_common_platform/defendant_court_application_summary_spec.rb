RSpec.describe HmctsCommonPlatform::DefendantCourtApplicationSummary, type: :model do
  let(:defendant_court_application_summary) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("defendant_court_application_summary/all_fields.json").read) }

    it "matches the schema" do
      expect(data).to match_json_schema(:defendant_court_application_summary)
    end

    it { expect(defendant_court_application_summary.id).to eql("9aca847f-da4e-444b-8f5a-2ce7d776ab75") }
    it { expect(defendant_court_application_summary.short_id).to eql("A25ULRHLVC7S") }
    it { expect(defendant_court_application_summary.reference).to eql("03811314") }
    it { expect(defendant_court_application_summary.title).to eql("Appeal against conviction") }
    it { expect(defendant_court_application_summary.received_date).to eql("2025-04-11") }
    it { expect(defendant_court_application_summary.master_defendant_id).to eql("64a7e770-93b2-4971-ae38-2ed3fd06252e") }
  end

  context "with only required fields" do
    let(:data) { JSON.parse(file_fixture("defendant_court_application_summary/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:defendant_court_application_summary)
    end

    it { expect(defendant_court_application_summary.id).to eql("9aca847f-da4e-444b-8f5a-2ce7d776ab75") }
    it { expect(defendant_court_application_summary.short_id).to eql("A25ULRHLVC7S") }
    it { expect(defendant_court_application_summary.reference).to eql("03811314") }
    it { expect(defendant_court_application_summary.title).to eql("Appeal against conviction") }
    it { expect(defendant_court_application_summary.received_date).to eql("2025-04-11") }
  end

  describe "#to_json" do
    let(:data) { JSON.parse(file_fixture("defendant_court_application_summary/all_fields.json").read) }

    it "generates a JSON representation of the data" do
      json = defendant_court_application_summary.to_json

      expect(json["id"]).to eql("9aca847f-da4e-444b-8f5a-2ce7d776ab75")
      expect(json["short_id"]).to eql("A25ULRHLVC7S")
      expect(json["reference"]).to eql("03811314")
      expect(json["title"]).to eql("Appeal against conviction")
      expect(json["received_date"]).to eql("2025-04-11")
    end
  end
end
