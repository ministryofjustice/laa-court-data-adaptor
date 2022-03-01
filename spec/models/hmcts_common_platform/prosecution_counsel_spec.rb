RSpec.describe HmctsCommonPlatform::ProsecutionCounsel, type: :model do
  let(:prosecution_counsel) { described_class.new(data) }

  let(:data) { JSON.parse(file_fixture("prosecution_counsel.json").read) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:prosecution_counsel)
  end

  it "generates a JSON representation of the data" do
    expect(prosecution_counsel.to_json["title"]).to eql("Ms")
    expect(prosecution_counsel.to_json["first_name"]).to eql("Phoebe")
    expect(prosecution_counsel.to_json["middle_name"]).to eql("Lucy")
    expect(prosecution_counsel.to_json["last_name"]).to eql("Buffay")
    expect(prosecution_counsel.to_json["status"]).to eql("junior counsel")
    expect(prosecution_counsel.to_json["attendance_days"]).to eql(%w[2021-06-01])
    expect(prosecution_counsel.to_json["prosecution_cases"]).to eql(%w[9590fb09-1074-4f67-8fb2-52922927b71e])
  end

  it { expect(prosecution_counsel.title).to eql("Ms") }
  it { expect(prosecution_counsel.first_name).to eql("Phoebe") }
  it { expect(prosecution_counsel.middle_name).to eql("Lucy") }
  it { expect(prosecution_counsel.last_name).to eql("Buffay") }
  it { expect(prosecution_counsel.status).to eql("junior counsel") }
  it { expect(prosecution_counsel.attendance_days).to eql(%w[2021-06-01]) }
  it { expect(prosecution_counsel.prosecution_cases).to eql(%w[9590fb09-1074-4f67-8fb2-52922927b71e]) }
end
