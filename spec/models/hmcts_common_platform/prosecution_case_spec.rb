RSpec.describe HmctsCommonPlatform::ProsecutionCase, type: :model do
  let(:prosecution_case) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("prosecution_case/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:prosecution_case)
    end

    it "generates a JSON representation of the data" do
      expect(prosecution_case.to_json["prosecution_case_identifier"]).to be_present
      expect(prosecution_case.to_json["status"]).to eql("CLOSED")
      expect(prosecution_case.to_json["statement_of_facts"]).to eql("Veritatis cardigan +1.")
      expect(prosecution_case.to_json["statement_of_facts_welsh"]).to eql("Actually small batch in ea.")
    end

    it { expect(prosecution_case.urn).to eql("20GD0217100") }
    it { expect(prosecution_case.status).to eql("CLOSED") }
    it { expect(prosecution_case.prosecution_case_identifier).to be_an(HmctsCommonPlatform::ProsecutionCaseIdentifier) }
    it { expect(prosecution_case.defendant_ids).to eql(%w[2ecc9feb-9407-482f-b081-d9e5c8ba3ed3]) }
    it { expect(prosecution_case.defendants).to all(be_an(HmctsCommonPlatform::Defendant)) }
    it { expect(prosecution_case.statement_of_facts).to eql("Veritatis cardigan +1.") }
    it { expect(prosecution_case.statement_of_facts_welsh).to eql("Actually small batch in ea.") }
  end

  context "with required fields only" do
    let(:data) { JSON.parse(file_fixture("prosecution_case/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:prosecution_case)
    end

    it { expect(prosecution_case.urn).to eql("20GD0217100") }
    it { expect(prosecution_case.prosecution_case_identifier).to be_an(HmctsCommonPlatform::ProsecutionCaseIdentifier) }
    it { expect(prosecution_case.defendants).to all(be_an(HmctsCommonPlatform::Defendant)) }
  end
end
