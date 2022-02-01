RSpec.describe HmctsCommonPlatform::HearingDay, type: :model do
  let(:hearing_day) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("hearing_day/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:hearing_day)
    end

    it { expect(hearing_day.sitting_day).to eq("2021-03-25T09:30:00.000Z") }
    it { expect(hearing_day.listing_sequence).to eq(8) }
    it { expect(hearing_day.listed_duration_minutes).to eq(20) }
    it { expect(hearing_day.has_shared_results).to be true }
  end

  context "with required fields only" do
    let(:data) { JSON.parse(file_fixture("hearing_day/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:hearing_day)
    end

    it { expect(hearing_day.sitting_day).to eq("2021-03-25T09:30:00.000Z") }
    it { expect(hearing_day.listing_sequence).to be_nil }
    it { expect(hearing_day.listed_duration_minutes).to eq(20) }
  end

  describe "#to_json" do
    let(:data) { JSON.parse(file_fixture("hearing_day/all_fields.json").read) }

    it "generates a JSON representation of the data" do
      json = hearing_day.to_json

      expect(json["sitting_day"]).to eql("2021-03-25T09:30:00.000Z")
      expect(json["listing_sequence"]).to be(8)
      expect(json["listed_duration_minutes"]).to be(20)
      expect(json["has_shared_results"]).to be true
    end
  end
end
