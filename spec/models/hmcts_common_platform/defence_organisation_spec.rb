RSpec.describe HmctsCommonPlatform::DefenceOrganisation, type: :model do
  let(:defence_organisation) { described_class.new(data) }

  context "when the defence_organisation has all fields" do
    let(:data) { JSON.parse(file_fixture("defence_organisation/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:defence_organisation)
    end

    it "generates a JSON representation of the data" do
      expect(defence_organisation.to_json["laa_contract_number"]).to eql("11223344")
      expect(defence_organisation.to_json["organisation"]).to be_present
    end

    it { expect(defence_organisation.laa_contract_number).to eql("11223344") }
    it { expect(defence_organisation.organisation).to be_an(HmctsCommonPlatform::Organisation) }
  end
end
