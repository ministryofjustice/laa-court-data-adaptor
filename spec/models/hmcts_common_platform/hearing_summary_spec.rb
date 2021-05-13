RSpec.describe HmctsCommonPlatform::HearingSummary, type: :model do
  let(:hearing_summary) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("hearing_summary/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:hearing_summary)
    end

    it { expect(hearing_summary.hearing_id).to eql("9b8df2aa-802d-413a-82b3-89eff25cde7b") }
    it { expect(hearing_summary.hearing_type).to eql("First hearing") }
    it { expect(hearing_summary.hearing_days).to all(be_an(HmctsCommonPlatform::HearingDay)) }
    it { expect(hearing_summary.court_centre).to be_an(HmctsCommonPlatform::CourtCentre) }
  end

  context "with required fields only" do
    let(:data) { JSON.parse(file_fixture("hearing_summary/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:hearing_summary)
    end

    it { expect(hearing_summary.hearing_id).to eql("9b8df2aa-802d-413a-82b3-89eff25cde7b") }
    it { expect(hearing_summary.hearing_type).to eql("First hearing") }
    it { expect(hearing_summary.hearing_days).to be_empty }
    it { expect(hearing_summary.court_centre).to be_an(HmctsCommonPlatform::CourtCentre) }
  end
end
