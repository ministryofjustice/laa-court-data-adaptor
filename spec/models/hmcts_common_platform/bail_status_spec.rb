RSpec.describe HmctsCommonPlatform::BailStatus, type: :model do
  let(:data) { JSON.parse(file_fixture("bail_status.json").read) }
  let(:bail_status) { described_class.new(data) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:bail_status)
  end

  it "generates a JSON representation of the data" do
    expect(bail_status.to_json["code"]).to eql("C")
    expect(bail_status.to_json["description"]).to eql("Custody or remanded into custody")
  end

  it { expect(bail_status.code).to eql("C") }
  it { expect(bail_status.description).to eql("Custody or remanded into custody") }
end
