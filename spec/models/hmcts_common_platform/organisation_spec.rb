RSpec.describe HmctsCommonPlatform::Organisation, type: :model do
  subject(:organisation) { described_class.new(data) }

  let(:data) { JSON.parse(file_fixture("organisation.json").read) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:organisation)
  end

  it "generates a JSON representation of the data" do
    expect(organisation.to_json["name"]).to eq("The Johnson Partnership")
    expect(organisation.to_json["incorporation_number"]).to eql("1234")
    expect(organisation.to_json["registered_charity_number"]).to eql("5678")
    expect(organisation.to_json["address"]).to be_present
    expect(organisation.to_json["contact"]).to be_present
  end

  it { expect(organisation.name).to eq("The Johnson Partnership") }
  it { expect(organisation.incorporation_number).to eql("1234") }
  it { expect(organisation.registered_charity_number).to eql("5678") }
  it { expect(organisation.address).to be_an(HmctsCommonPlatform::Address) }
  it { expect(organisation.contact).to be_an(HmctsCommonPlatform::ContactDetails) }
end
