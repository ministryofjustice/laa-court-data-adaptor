RSpec.describe HmctsCommonPlatform::SearchProsecutionCaseResponse, type: :model do
  let(:search_prosecution_case_response) { described_class.new(data) }
  let(:data) { JSON.parse(file_fixture("search_prosecution_case_response.json").read) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:search_prosecution_case_response)
  end

  it { expect(search_prosecution_case_response.cases).to all be_an(HmctsCommonPlatform::ProsecutionCaseSummary) }
  it { expect(search_prosecution_case_response.total_results).to be(1) }
end
