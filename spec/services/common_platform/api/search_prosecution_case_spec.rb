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
      .with(prosecution_case_id:, body: response_body["cases"][0])
    search_prosecution_case
  end

  it "returns the recorded ProsecutionCases" do
    expect(search_prosecution_case).to all(be_a(ProsecutionCase))
  end

  context "when the cases contain the applicationSummary" do
    let(:response_body) do
      JSON.parse(file_fixture("prosecution_case_search_result_with_application_summary.json").read)
    end

    it "contains applicationSummary" do
      expect(search_prosecution_case[0].body["applicationSummary"]).to be_present
      expect(search_prosecution_case[1].body["applicationSummary"]).to be_present
    end
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

  context "when contains a blank defendant" do
    let(:response_body) { JSON.parse(file_fixture("prosecution_case_search_result_with_only_blank_defendant.json").read) }
    let(:empty_defendant) { "4e5da043-d327-429a-bb5d-ed05734caa8e" }

    before do
      allow(Rails.logger).to receive(:error)
      allow(Sentry).to receive(:capture_message)

      search_prosecution_case_object = described_class.new(params)
      search_prosecution_case_object.call
    end

    it "logs an error" do
      expect(Rails.logger).to have_received(:error)
        .with("The defendant with the defendantId [#{empty_defendant}] is blank (missing defendantFirstName, defendantLastName, defendantDOB, defendantNINO and hearingSummary)")
    end

    it "sends a message to Sentry" do
      expect(Sentry).to have_received(:capture_message).with("The defendant with the defendantId [#{empty_defendant}] is blank (missing defendantFirstName, defendantLastName, defendantDOB, defendantNINO and hearingSummary)")
    end
  end

  context "when contains a blank defendant but they are present in the hearing summary" do
    let(:response_body) { JSON.parse(file_fixture("prosecution_case_search_result_with_blank_defendant_present_in_hearing_summary.json").read) }
    let(:empty_defendant) { "4e5da043-d327-429a-bb5d-ed05734caa8e" }

    before do
      allow(Rails.logger).to receive(:error)
      allow(Sentry).to receive(:capture_message)

      search_prosecution_case_object = described_class.new(params)
      search_prosecution_case_object.call
    end

    it "does not log an error" do
      expect(Rails.logger).not_to have_received(:error)
                                .with("The defendant with the defendantId [#{empty_defendant}] is blank (missing defendantFirstName, defendantLastName, defendantDOB, defendantNINO and hearingSummary)")
    end

    it "does not send a message to Sentry" do
      expect(Sentry).not_to have_received(:capture_message).with("The defendant with the defendantId [#{empty_defendant}] is blank (missing defendantFirstName, defendantLastName, defendantDOB, defendantNINO and hearingSummary)")
    end
  end

  context "when contains a blank defendant and a non-blank defendant" do
    let(:response_body) { JSON.parse(file_fixture("prosecution_case_search_result_with_blank_and_non_blank_defendant.json").read) }
    let(:empty_defendant) { "77908e28-254c-4c02-858c-d012d20f1901" }
    let(:non_empty_defendant) { "0e70b6f9-b488-4827-9658-956e4f6e3d48" }

    before do
      allow(Rails.logger).to receive(:error)
      allow(Sentry).to receive(:capture_message)

      search_prosecution_case_object = described_class.new(params)
      search_prosecution_case_object.call
    end

    it "logs an error for the blank defendant and doesnt log a warning for the non-blank defendant" do
      expect(Rails.logger).to have_received(:error)
        .with("The defendant with the defendantId [#{empty_defendant}] is blank (missing defendantFirstName, defendantLastName, defendantDOB, defendantNINO and hearingSummary)")
        .exactly(1).times

      expect(Rails.logger).not_to have_received(:error)
        .with("The defendant with the defendantId [#{non_empty_defendant}] is blank (missing defendantFirstName, defendantLastName, defendantDOB, defendantNINO and hearingSummary)")
    end

    it "sends a message to Sentry" do
      expect(Sentry).to have_received(:capture_message).with("The defendant with the defendantId [#{empty_defendant}] is blank (missing defendantFirstName, defendantLastName, defendantDOB, defendantNINO and hearingSummary)")
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
