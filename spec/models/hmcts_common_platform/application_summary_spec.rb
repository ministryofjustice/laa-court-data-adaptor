RSpec.describe HmctsCommonPlatform::ApplicationSummary, type: :model do
  let(:application_summary) { described_class.new(data) }

  let(:data) { JSON.parse(file_fixture("application_summary/all_fields.json").read) }

  context "with all fields" do
    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:application_summary)
    end

    it { expect(application_summary.id).to eql("6cd6494e-5409-420a-bd0b-f589dbb2466b") }
    it { expect(application_summary.reference).to eql("CJ03511") }
    it { expect(application_summary.title).to eql("Conviction of an offence while a community order is in force") }
    it { expect(application_summary.received_date).to eql("2024-12-15") }
    it { expect(application_summary.short_id).to eql("A25ABCDE1234") }
    it { expect(application_summary.subject_summary).to be_a(HmctsCommonPlatform::SubjectSummary) }
  end

  describe "#to_json" do
    it "generates a JSON representation of the data" do
      json = application_summary.to_json

      expect(json["id"]).to eql("6cd6494e-5409-420a-bd0b-f589dbb2466b")
      expect(json["reference"]).to eql("CJ03511")
      expect(json["title"]).to eql("Conviction of an offence while a community order is in force")
      expect(json["received_date"]).to eql("2024-12-15")
      expect(json["short_id"]).to eql("A25ABCDE1234")
      expect(json["subject_summary"]).to be_a(Hash)
    end
  end
end
