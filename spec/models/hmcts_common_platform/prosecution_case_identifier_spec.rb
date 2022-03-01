RSpec.describe HmctsCommonPlatform::ProsecutionCaseIdentifier, type: :model do
  let(:prosecution_case_identifier) { described_class.new(data) }

  let(:data) { JSON.parse(file_fixture("prosecution_case_identifier.json").read) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:prosecution_case_identifier)
  end

  it "generates a JSON representation of the data" do
    expect(prosecution_case_identifier.to_json["case_urn"]).to eql("HHBCYLSNHM")
    expect(prosecution_case_identifier.to_json["prosecution_authority_id"]).to eql("a20d0b0c-7d10-4647-82cd-8c7dd1e0a4ea")
    expect(prosecution_case_identifier.to_json["prosecution_authority_code"]).to eql("JSAXISTNEG")
    expect(prosecution_case_identifier.to_json["prosecution_authority_name"]).to eql("Authority Name")
  end

  it { expect(prosecution_case_identifier.case_urn).to eql("HHBCYLSNHM") }
  it { expect(prosecution_case_identifier.prosecution_authority_id).to eql("a20d0b0c-7d10-4647-82cd-8c7dd1e0a4ea") }
  it { expect(prosecution_case_identifier.prosecution_authority_code).to eql("JSAXISTNEG") }
  it { expect(prosecution_case_identifier.prosecution_authority_name).to eql("Authority Name") }
end
