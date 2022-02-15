RSpec.describe HmctsCommonPlatform::JudicialRole, type: :model do
  let(:judicial_role) { described_class.new(data) }

  let(:data) { JSON.parse(file_fixture("judicial_role.json").read) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:judicial_role)
  end

  it "generates a JSON representation of the data" do
    expect(judicial_role.to_json["title"]).to eql("Ms")
    expect(judicial_role.to_json["first_name"]).to eql("Phoebe")
    expect(judicial_role.to_json["middle_name"]).to eql("Lucy")
    expect(judicial_role.to_json["last_name"]).to eql("Buffay")
    expect(judicial_role.to_json["type"]).to eql("Judge")
    expect(judicial_role.to_json["is_deputy"]).to be true
    expect(judicial_role.to_json["is_bench_chairman"]).to be true
  end

  it { expect(judicial_role.title).to eql("Ms") }
  it { expect(judicial_role.first_name).to eql("Phoebe") }
  it { expect(judicial_role.middle_name).to eql("Lucy") }
  it { expect(judicial_role.last_name).to eql("Buffay") }
  it { expect(judicial_role.type).to eql("Judge") }
  it { expect(judicial_role.is_deputy).to be true }
  it { expect(judicial_role.is_bench_chairman).to be true }
end
