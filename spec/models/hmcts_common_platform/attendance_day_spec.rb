RSpec.describe HmctsCommonPlatform::AttendanceDay, type: :model do
  let(:data) { JSON.parse(file_fixture("attendance_day.json").read) }
  let(:attendance_day) { described_class.new(data) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:attendance_day)
  end

  it "generates a JSON representation of the data" do
    expect(attendance_day.to_json["type"]).to eql("IN_PERSON")
    expect(attendance_day.to_json["day"]).to eql("2021-05-11")
  end

  it { expect(attendance_day.type).to eql("IN_PERSON") }
  it { expect(attendance_day.day).to eql("2021-05-11") }
end
