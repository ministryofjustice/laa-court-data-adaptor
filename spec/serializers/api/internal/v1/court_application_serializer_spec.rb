RSpec.describe Api::Internal::V1::CourtApplicationSerializer do
  let(:court_application_data) { JSON.parse(file_fixture("court_application.json").read) }
  let(:court_application) { HmctsCommonPlatform::CourtApplication.new(court_application_data) }

  it "serializes court application data" do
    expected = {
      data: {
        id: "c5266a93-389c-4331-a56a-dd000b361cef",
        type: :court_application,
        attributes: {
          received_date: "2021-03-09",
        },
        relationships: {
          type: {
            data: {
              id: "74b72f6f-414a-3464-a4a2-d91397b4c439",
              type: :court_application_type,
            },
          },
          judicial_results: {
            data: [
              {
                id: "be225605-fc15-47aa-b74c-efb8629db58e",
                type: :judicial_result,
              },
            ],
          },
          respondents: {
            data: [
              {
                id: "4f59e8d5-53d5-4175-b9b3-d46363671d03",
                type: :court_application_party,
              },
            ],
          },
        },
      },
    }

    expect(described_class.new(court_application).serializable_hash).to eql(expected)
  end
end
