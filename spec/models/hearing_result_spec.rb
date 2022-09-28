RSpec.describe HearingResult, type: :model do
  let(:data) { JSON.parse(file_fixture("hearing_resulted.json").read) }
  let(:hearing_result) { described_class.new(data) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:hearing_resulted)
  end

  it "has a hearing" do
    expect(hearing_result.hearing).to be_a(Hearing)
  end

  it "has a shared time" do
    expect(hearing_result.shared_time).to eql("2020-10-30T10:04:27.476+00:00")
  end
end
