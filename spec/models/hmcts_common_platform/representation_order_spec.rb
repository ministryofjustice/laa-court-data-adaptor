RSpec.describe HmctsCommonPlatform::RepresentationOrder, type: :model do
  let(:representation_order) { described_class.new(data) }

  let(:data) { JSON.parse(file_fixture("representation_order.json").read) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:representation_order)
  end

  it { expect(representation_order.application_reference).to eql("7157555") }
  it { expect(representation_order.effective_start_date).to eql("2021-12-09") }
  it { expect(representation_order.effective_end_date).to eql("2021-12-10") }
  it { expect(representation_order.laa_contract_number).to eql("0N824P") }

  describe "#to_json" do
    let(:data) { JSON.parse(file_fixture("representation_order.json").read) }

    it "generates a JSON representation of the data" do
      json = representation_order.to_json

      expect(json["application_reference"]).to eql("7157555")
      expect(json["effective_start_date"]).to eql("2021-12-09")
      expect(json["effective_end_date"]).to eql("2021-12-10")
      expect(json["laa_contract_number"]).to eql("0N824P")
    end
  end
end
