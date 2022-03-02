RSpec.describe HmctsCommonPlatform::HearingEventLog, type: :model do
  let(:hearing_event) { described_class.new(data) }

  let(:data) { JSON.parse(file_fixture("valid_hearing_logs.json").read) }

  describe "fixture data" do
    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:hearing_event_log)
    end
  end

  it "generates a JSON representation of the data" do
    expect(hearing_event.to_json["hearing_id"]).to eql("2c24f897-ffc4-439f-9c4a-ec60c7715cd0")
    expect(hearing_event.to_json["has_active_hearing"]).to be true
    expect(hearing_event.to_json["events"]).to be_present
  end

  it { expect(hearing_event.hearing_id).to eql("2c24f897-ffc4-439f-9c4a-ec60c7715cd0") }
  it { expect(hearing_event.has_active_hearing).to be true }
  it { expect(hearing_event.events).to all(be_an(HmctsCommonPlatform::HearingEvent)) }
end
