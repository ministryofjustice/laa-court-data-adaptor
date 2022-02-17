RSpec.describe HmctsCommonPlatform::LaaReference, type: :model do
  let(:laa_reference) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("laa_reference/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:laa_reference)
    end

    it { expect(laa_reference.reference).to eql("A10000099") }
    it { expect(laa_reference.status_code).to eql("AP") }
    it { expect(laa_reference.status_date).to eql("2020-11-05") }
    it { expect(laa_reference.status_description).to eql("LAA status description") }
    it { expect(laa_reference.effective_start_date).to eql("2021-04-10") }
    it { expect(laa_reference.effective_end_date).to eql("2021-04-11") }
    it { expect(laa_reference.laa_contract_number).to eql("27900") }
  end

  context "with required fields only" do
    let(:data) { JSON.parse(file_fixture("laa_reference/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:laa_reference)
    end

    it { expect(laa_reference.reference).to eql("A10000099") }
    it { expect(laa_reference.status_code).to eql("AP") }
    it { expect(laa_reference.status_date).to eql("2020-11-05") }
    it { expect(laa_reference.status_description).to eql("LAA status description") }
    it { expect(laa_reference.effective_start_date).to be_nil }
    it { expect(laa_reference.effective_end_date).to be_nil }
    it { expect(laa_reference.laa_contract_number).to be_nil }
  end

  describe "#to_json" do
    let(:data) { JSON.parse(file_fixture("laa_reference/all_fields.json").read) }

    it "generates a JSON representation of the data" do
      expect(laa_reference.to_json["reference"]).to eql("A10000099")
      expect(laa_reference.to_json["id"]).to eql("38944fbb-c8a6-45ff-9b5c-e09e9867eabc")
      expect(laa_reference.to_json["status_code"]).to eql("AP")
      expect(laa_reference.to_json["status_date"]).to eql("2020-11-05")
      expect(laa_reference.to_json["description"]).to eql("LAA status description")
      expect(laa_reference.to_json["effective_start_date"]).to eql("2021-04-10")
      expect(laa_reference.to_json["effective_end_date"]).to eql("2021-04-11")
      expect(laa_reference.to_json["contract_number"]).to eql("27900")
    end
  end
end
