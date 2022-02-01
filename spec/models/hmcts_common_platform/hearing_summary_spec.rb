RSpec.describe HmctsCommonPlatform::HearingSummary, type: :model do
  let(:hearing_summary) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("hearing_summary/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:hearing_summary)
    end

    it { expect(hearing_summary.id).to eql("9b8df2aa-802d-413a-82b3-89eff25cde7b") }
    it { expect(hearing_summary.hearing_type).to eql("First hearing") }
    it { expect(hearing_summary.estimated_duration).to eq("20") }
    it { expect(hearing_summary.hearing_days).to all(be_an(HmctsCommonPlatform::HearingDay)) }
    it { expect(hearing_summary.court_centre).to be_an(HmctsCommonPlatform::CourtCentre) }
    it { expect(hearing_summary.defence_counsels).to all(be_a(HmctsCommonPlatform::DefenceCounsel)) }
  end

  context "with required fields only" do
    let(:data) { JSON.parse(file_fixture("hearing_summary/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:hearing_summary)
    end

    it { expect(hearing_summary.id).to eql("9b8df2aa-802d-413a-82b3-89eff25cde7b") }
    it { expect(hearing_summary.hearing_type).to eql("First hearing") }
    it { expect(hearing_summary.hearing_days).to be_empty }
    it { expect(hearing_summary.court_centre).to be_an(HmctsCommonPlatform::CourtCentre) }
  end

  describe "#to_json" do
    let(:data) { JSON.parse(file_fixture("hearing_summary/all_fields.json").read) }

    it "generates a JSON representation of the data" do
      json = hearing_summary.to_json

      expect(json["id"]).to eql("9b8df2aa-802d-413a-82b3-89eff25cde7b")
      expect(json["hearing_type"]).to eql("First hearing")
      expect(json["estimated_duration"]).to eql("20")
      expect(json["court_centre"]).to be_present
      expect(json["hearing_days"].count).to be(1)
      expect(json["defence_counsels"].count).to be(1)
    end
  end
end
