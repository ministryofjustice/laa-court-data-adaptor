RSpec.describe HmctsCommonPlatform::RespondentCounsel, type: :model do
  let(:respondent_counsel) { described_class.new(data) }

  let(:data) { JSON.parse(file_fixture("respondent_counsel.json").read) }

  it "generates a JSON representation of the data" do
    expect(respondent_counsel.to_json["title"]).to eql("Mr")
    expect(respondent_counsel.to_json["first_name"]).to eql("John Test")
    expect(respondent_counsel.to_json["middle_name"]).to be_nil
    expect(respondent_counsel.to_json["last_name"]).to eql("Doe")
    expect(respondent_counsel.to_json["status"]).to eql("Leading junior")
    expect(respondent_counsel.to_json["attendance_days"]).to eql(%w[2025-07-29])
  end

  it { expect(respondent_counsel.title).to eql("Mr") }
  it { expect(respondent_counsel.first_name).to eql("John Test") }
  it { expect(respondent_counsel.middle_name).to be_nil }
  it { expect(respondent_counsel.last_name).to eql("Doe") }
  it { expect(respondent_counsel.status).to eql("Leading junior") }
  it { expect(respondent_counsel.attendance_days).to eql(%w[2025-07-29]) }
end
