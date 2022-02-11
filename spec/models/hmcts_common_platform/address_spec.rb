RSpec.describe HmctsCommonPlatform::Address, type: :model do
  let(:address) { described_class.new(data) }

  context "when verdict has all fields" do
    let(:data) { JSON.parse(file_fixture("address.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:address)
    end

    it "generates a JSON representation of the data" do
      expect(address.to_json["address_1"]).to eql("Address 1")
      expect(address.to_json["address_2"]).to eql("Address 2")
      expect(address.to_json["address_3"]).to eql("Address 3")
      expect(address.to_json["address_4"]).to eql("Address 4")
      expect(address.to_json["address_5"]).to eql("Address 5")
      expect(address.to_json["postcode"]).to eql("DL5 8TY")
    end

    it { expect(address.address_1).to eql("Address 1") }
    it { expect(address.address_2).to eql("Address 2") }
    it { expect(address.address_3).to eql("Address 3") }
    it { expect(address.address_4).to eql("Address 4") }
    it { expect(address.address_5).to eql("Address 5") }
    it { expect(address.postcode).to eql("DL5 8TY") }
  end
end
