RSpec.describe HmctsCommonPlatform::OffenceSummary, type: :model do
  let(:offence_summary) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("offence_summary/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:offence_summary)
    end

    it { expect(offence_summary.offence_id).to eq("9aca847f-da4e-444b-8f5a-2ce7d776ab75") }
    it { expect(offence_summary.offence_code).to eq("TH68026C") }
    it { expect(offence_summary.title).to eq("Conspire to commit a burglary dwelling with intent to steal") }
    it { expect(offence_summary.order_index).to eq(1) }
    it { expect(offence_summary.mode_of_trial).to eq("Indictable") }
    it { expect(offence_summary.start_date).to eq("2021-03-06") }
    it { expect(offence_summary.wording).to eq("Between 06.03.2021 and 22.03.2021 at DERBY in the county of DERBYSHIRE, conspired together with John Doe to enter as a trespasser") }
  end

  context "with required fields only" do
    let(:data) { JSON.parse(file_fixture("offence_summary/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:offence_summary)
    end

    it { expect(offence_summary.offence_id).to eq("9aca847f-da4e-444b-8f5a-2ce7d776ab75") }
    it { expect(offence_summary.offence_code).to eq("TH68026C") }
    it { expect(offence_summary.title).to eq("Conspire to commit a burglary dwelling with intent to steal") }
    it { expect(offence_summary.order_index).to be_nil }
    it { expect(offence_summary.mode_of_trial).to be_nil }
    it { expect(offence_summary.start_date).to be_nil }
    it { expect(offence_summary.wording).to be_nil }
  end
end
