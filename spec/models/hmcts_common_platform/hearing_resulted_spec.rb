RSpec.describe HmctsCommonPlatform::HearingResulted, type: :model do
  let(:data) { JSON.parse(file_fixture("hearing_resulted.json").read) }
  let(:hearing_resulted) { described_class.new(data) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:hearing_resulted)
  end

  it "has a hearing" do
    expect(hearing_resulted.hearing).to be_an(HmctsCommonPlatform::Hearing)
  end

  it "has a shared time" do
    expect(hearing_resulted.shared_time).to eql("2020-10-30T10:04:27.476+00:00")
  end

  describe "#to_json" do
    it "generates a JSON representation of the data" do
      json = hearing_resulted.to_json

      expect(json["hearing"]).to be_present
      expect(json["shared_time"]).to eql("2020-10-30T10:04:27.476+00:00")
    end
  end
end
