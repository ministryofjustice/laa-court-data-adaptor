RSpec.describe HmctsCommonPlatform::ApplicationSummary, type: :model do
  let(:hearing_summary) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("application_summary/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:application_summary)
    end

    it { expect(hearing_summary.id).to eql("6cd6494e-5409-420a-bd0b-f589dbb2466b") }
    it { expect(hearing_summary.reference).to eql("CJ03511") }
    it { expect(hearing_summary.title).to eql("Conviction of an offence while a community order is in force") }
    it { expect(hearing_summary.received_date).to eql("2024-12-15") }
  end
end
