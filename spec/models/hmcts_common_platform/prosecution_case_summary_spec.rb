RSpec.describe HmctsCommonPlatform::ProsecutionCaseSummary, type: :model do
  let(:prosecution_case_summary) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("prosecution_case_summary/all_fields.json").read) }

    it { expect(prosecution_case_summary.prosecution_case_reference).to eq("30DI0570888") }
    it { expect(prosecution_case_summary.case_status).to eq("ACTIVE") }
    it { expect(prosecution_case_summary.defendant_summaries).to all be_an(HmctsCommonPlatform::DefendantSummary) }
    it { expect(prosecution_case_summary.hearing_summaries).to all be_an(HmctsCommonPlatform::HearingSummary) }
  end

  context "with required fields only" do
    let(:data) { JSON.parse(file_fixture("prosecution_case_summary/required_fields.json").read) }

    it { expect(prosecution_case_summary.prosecution_case_reference).to eq("30DI0570888") }
    it { expect(prosecution_case_summary.case_status).to eq("ACTIVE") }
    it { expect(prosecution_case_summary.defendant_summaries).to all be_an(HmctsCommonPlatform::DefendantSummary) }
    it { expect(prosecution_case_summary.hearing_summaries).to be_empty }
  end
end
