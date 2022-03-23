RSpec.describe HmctsCommonPlatform::DefendantAttendance, type: :model do
  let(:data) { JSON.parse(file_fixture("defendant_attendance.json").read) }
  let(:defendant_attendance) { described_class.new(data) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:defendant_attendance)
  end

  it "generates a JSON representation of the data" do
    expect(defendant_attendance.to_json["defendant_id"]).to eql("fe51e09a-56a2-4bd8-9ad9-cea8926735ec")
    expect(defendant_attendance.to_json["attendance_days"]).to be_present
  end

  it { expect(defendant_attendance.defendant_id).to eql("fe51e09a-56a2-4bd8-9ad9-cea8926735ec") }
  it { expect(defendant_attendance.attendance_days).to all be_an(HmctsCommonPlatform::AttendanceDay) }
end
