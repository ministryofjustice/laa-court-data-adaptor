RSpec.describe HmctsCommonPlatform::ApplicantCounsel, type: :model do
  let(:applicant_counsel) { described_class.new(data) }

  let(:data) { JSON.parse(file_fixture("applicant_counsel.json").read) }

  it "generates a JSON representation of the data" do
    expect(applicant_counsel.to_json["title"]).to eql("Ms")
    expect(applicant_counsel.to_json["first_name"]).to eql("Charlie Test")
    expect(applicant_counsel.to_json["middle_name"]).to be_nil
    expect(applicant_counsel.to_json["last_name"]).to eql("Advocate")
    expect(applicant_counsel.to_json["status"]).to eql("QC")
    expect(applicant_counsel.to_json["attendance_days"]).to eql(%w[2025-07-29])
    expect(applicant_counsel.to_json["applicants"]).to eql(%w[35df5b45-83e2-4419-8236-3eb15b43dc63])
  end

  it { expect(applicant_counsel.title).to eql("Ms") }
  it { expect(applicant_counsel.first_name).to eql("Charlie Test") }
  it { expect(applicant_counsel.middle_name).to be_nil }
  it { expect(applicant_counsel.last_name).to eql("Advocate") }
  it { expect(applicant_counsel.status).to eql("QC") }
  it { expect(applicant_counsel.attendance_days).to eql(%w[2025-07-29]) }
  it { expect(applicant_counsel.applicants).to eql(%w[35df5b45-83e2-4419-8236-3eb15b43dc63]) }
end
