RSpec.describe HmctsCommonPlatform::DefendantSummary, type: :model do
  let(:defendant_summary) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("defendant_summary/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:defendant_summary)
    end

    it { expect(defendant_summary.defendant_id).to eql("b760daba-0d38-4bae-ad57-fbfd8419aefe") }
    it { expect(defendant_summary.first_name).to eql("Bob") }
    it { expect(defendant_summary.last_name).to eql("Smith") }
    it { expect(defendant_summary.arrest_summons_number).to eql("2100000000000267128K") }
    it { expect(defendant_summary.date_of_birth).to eql("1986-11-10") }
    it { expect(defendant_summary.national_insurance_number).to eql("AA123456C") }
    it { expect(defendant_summary.offence_summaries).to all(be_an(HmctsCommonPlatform::OffenceSummary)) }
  end

  context "with only required fields" do
    let(:data) { JSON.parse(file_fixture("defendant_summary/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:defendant_summary)
    end

    it { expect(defendant_summary.defendant_id).to eql("b760daba-0d38-4bae-ad57-fbfd8419aefe") }
    it { expect(defendant_summary.name).to eql("Bob Smith") }
    it { expect(defendant_summary.first_name).to be_nil }
    it { expect(defendant_summary.last_name).to be_nil }
    it { expect(defendant_summary.arrest_summons_number).to be_nil }
    it { expect(defendant_summary.date_of_birth).to be_nil }
    it { expect(defendant_summary.national_insurance_number).to be_nil }
    it { expect(defendant_summary.offence_summaries).to all(be_an(HmctsCommonPlatform::OffenceSummary)) }
  end
end
