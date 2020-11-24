# frozen_string_literal: true

RSpec.describe ProsecutionCaseHearingsFetcher do
  let(:prosecution_case_id) { "5edd67eb-9d8c-44f2-a57e-c8d026defaa4" }
  let(:body) { JSON.parse(file_fixture("prosecution_case_search_result.json").read)["cases"][0] }

  let!(:prosecution_case) do
    ProsecutionCase.create!(
      id: prosecution_case_id,
      body: body,
    )
  end

  let(:hearing_id)   { "b935a64a-6d03-4da4-bba6-4d32cc2e7fb4" }
  let(:hearing_id_2) { "9161049a-bde1-4150-83e5-9d5212d762c2" }
  let(:hearing_id_3) { "e6487eac-df3d-4175-9c41-c2e90d0a8587" }

  subject { described_class.call(prosecution_case_id: prosecution_case_id) }

  it "triggers a call to Api::GetHearingResults" do
    expect(Api::GetHearingResults).to receive(:call).with(hearing_id: hearing_id, publish_to_queue: true)
    expect(Api::GetHearingResults).to receive(:call).with(hearing_id: hearing_id_2, publish_to_queue: true)
    expect(Api::GetHearingResults).to receive(:call).with(hearing_id: hearing_id_3, publish_to_queue: true)
    subject
  end

  context "when hearingSummary does not exist" do
    let(:body) do
      {
        "cases": [
          {
            "caseStatus": "CLOSED",
            "prosecutionCaseId": "5edd67eb-9d8c-44f2-a57e-c8d026defaa4",
            "defendantSummary": [],
          },
        ],
      }
    end

    it "does not trigger a call to Api::GetHearingResults" do
      expect(Api::GetHearingResults).not_to receive(:call)
      subject
    end
  end
end
