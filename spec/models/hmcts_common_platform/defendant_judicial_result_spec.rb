RSpec.describe HmctsCommonPlatform::DefendantJudicialResult, type: :model do
  let(:defendant_judicial_result) { described_class.new(data) }

  let(:data) { JSON.parse(file_fixture("defendant_judicial_result.json").read) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:defendant_judicial_result)
  end

  it "generates a JSON representation of the data" do
    expect(defendant_judicial_result.to_json["defendant_id"]).to eql("f4e0cc61-c816-4631-8b56-94d8b720f7ea")
    expect(defendant_judicial_result.to_json["judicial_result"]).to be_present
  end

  it { expect(defendant_judicial_result.defendant_id).to eql("f4e0cc61-c816-4631-8b56-94d8b720f7ea") }
  it { expect(defendant_judicial_result.judicial_result).to be_an(HmctsCommonPlatform::JudicialResult) }
end
