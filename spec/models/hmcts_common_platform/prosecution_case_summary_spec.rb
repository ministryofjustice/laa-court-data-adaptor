RSpec.describe HmctsCommonPlatform::ProsecutionCaseSummary, type: :model do
  let(:prosecution_case_summary) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("prosecution_case_summary/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:prosecution_case_summary)
    end

    it { expect(prosecution_case_summary.prosecution_case_reference).to eq("30DI0570888") }
    it { expect(prosecution_case_summary.case_status).to eq("ACTIVE") }
    it { expect(prosecution_case_summary.defendant_summaries).to all be_an(HmctsCommonPlatform::DefendantSummary) }
    it { expect(prosecution_case_summary.hearing_summaries).to all be_an(HmctsCommonPlatform::HearingSummary) }

    context "when data includes a supported-type court application" do
      before do
        data["applicationSummary"].first["applicationTitle"] = "Appeal against conviction by a Magistrates' Court to the Crown Court"
      end

      it "passes the application along to the appropriate defendant" do
        expect(prosecution_case_summary.defendant_summaries.first.application_summaries.count).to eq 1
      end
    end

    context "when data includes an unsupported-type court application" do
      before do
        data["applicationSummary"].first["applicationTitle"] = "Application to amend a community order on change of residence"
      end

      it "passes the application along to the appropriate defendant" do
        expect(prosecution_case_summary.defendant_summaries.first.application_summaries.count).to eq 0
      end
    end
  end

  context "with required fields only" do
    let(:data) { JSON.parse(file_fixture("prosecution_case_summary/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:prosecution_case_summary)
    end

    it { expect(prosecution_case_summary.prosecution_case_reference).to eq("30DI0570888") }
    it { expect(prosecution_case_summary.case_status).to eq("ACTIVE") }
    it { expect(prosecution_case_summary.defendant_summaries).to all be_an(HmctsCommonPlatform::DefendantSummary) }
    it { expect(prosecution_case_summary.hearing_summaries).to be_empty }
  end

  describe "#to_json" do
    let(:data) { JSON.parse(file_fixture("prosecution_case_summary/all_fields.json").read) }

    it "generates a JSON representation of the data" do
      json = prosecution_case_summary.to_json

      expect(json["prosecution_case_reference"]).to eql("30DI0570888")
      expect(json["case_status"]).to eql("ACTIVE")
      expect(json["defendant_summaries"].count).to be(2)
      expect(json["hearing_summaries"].count).to be(2)
    end
  end
end
