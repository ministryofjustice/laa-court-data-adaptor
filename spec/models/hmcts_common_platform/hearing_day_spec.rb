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
end
