RSpec.describe HmctsCommonPlatform::ApplicationSummary, type: :model do
  let(:hearing_summary) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("application_summary/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:application_summary)
    end

    it { expect(hearing_summary.id).to eql("62158b87-56fc-43cc-bbdc-d957d372420f") }
    it { expect(hearing_summary.reference).to eql("CJ03512") }
    it { expect(hearing_summary.type).to eql("Application to amend a community order on change of residence") }
    it { expect(hearing_summary.application_status).to eql("EJECTED") }
    it { expect(hearing_summary.application_external_creator_type).to eql("PROSECUTOR") }
    it { expect(hearing_summary.received_date).to eql("2024-12-21") }
    it { expect(hearing_summary.decision_date).to eql("2025-02-11") }
    it { expect(hearing_summary.due_date).to eql("2025-01-27") }
  end
end
