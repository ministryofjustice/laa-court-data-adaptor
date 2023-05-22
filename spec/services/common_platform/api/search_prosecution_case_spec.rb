# frozen_string_literal: true

RSpec.describe CommonPlatform::Api::SearchProsecutionCase do
  subject(:search_prosecution_case) { described_class.call(params) }

  let(:params) { { howdy: "hello" } }
  let(:response_status) { 200 }
  let(:response_body) { JSON.parse(file_fixture("prosecution_case_search_result.json").read) }
  let(:common_platform_api_search_results) { double("Response", status: response_status, body: response_body) }
  let(:prosecution_case_id) { "5edd67eb-9d8c-44f2-a57e-c8d026defaa4" }

  before do
    allow(CommonPlatform::Api::ProsecutionCaseSearcher).to receive(:call).and_return(common_platform_api_search_results)
  end

  it "records ProsecutionCase" do
    expect(ProsecutionCaseRecorder).to receive(:call)
      .with(prosecution_case_id: prosecution_case_id, body: response_body["cases"][0])
    search_prosecution_case
  end

  it "returns the recorded ProsecutionCases" do
    expect(search_prosecution_case).to all(be_a(ProsecutionCase))
  end

  context "when containing multiple records" do
    let(:response_body) do
      {
        "totalResults" => 2,
        "cases" => [
          {
            "prosecutionCaseId" => 12_345,
          },
          {
            "prosecutionCaseId" => 23_456,
          },
        ],
      }
    end

    it "records each ProsecutionCase" do
      expect(ProsecutionCaseRecorder).to receive(:call).twice
      search_prosecution_case
    end
  end

  context "when containing no records" do
    let(:response_body) do
      {
        "totalResults" => 0,
        "cases" => [],
      }
    end

    it "does not record" do
      expect(ProsecutionCaseRecorder).not_to receive(:call)
      search_prosecution_case
    end
  end

  context "when the response is not a 200 Success" do
    let(:response_status) { 424 }

    # NOTE: In case of error, Common Platform API returns an HTML.
    let(:response_body) { "<html<body>error message<body></html>" }

    it "raises FailedDependency exception" do
      expect { search_prosecution_case }.to raise_error(
        CommonPlatform::Api::Errors::FailedDependency,
        "Common Platform API status: 424, body: error message",
      )
    end
  end
end
