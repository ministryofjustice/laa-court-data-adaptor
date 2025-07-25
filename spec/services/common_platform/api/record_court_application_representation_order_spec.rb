# frozen_string_literal: true

RSpec.describe CommonPlatform::Api::RecordCourtApplicationRepresentationOrder do
  subject(:record_representation_order) do
    described_class.call(
      court_application_id: court_application.id,
      subject_id:,
      offence_id:,
      status_code: "ABCDEF",
      application_reference: 999_999,
      status_date: "2019-12-12",
      effective_start_date: "2019-12-15",
      effective_end_date: "2020-12-15",
      defence_organisation:,
      connection:,
    )
  end

  let(:court_application) { CourtApplication.create!(id: "5edd67eb-9d8c-44f2-a57e-c8d026defaa4", body: "{}", subject_id:) }
  let(:subject_id) { "2ecc9feb-9407-482f-b081-d9e5c8ba3ed3" }
  let(:offence_id) { "3f153786-f3cf-4311-bc0c-2d6f48af68a1" }
  let(:connection) { double("CommonPlatform::Connection") } # rubocop:disable RSpec/VerifiedDoubles
  let(:defence_organisation) do
    {
      "organisation" => {
        "name" => "SOME ORGANISATION",
      },
      "laaContractNumber" => "CONTRACT REFERENCE",
    }
  end

  let(:request_params) do
    {
      statusCode: "ABCDEF",
      applicationReference: "999999",
      statusDate: "2019-12-12",
      effectiveStartDate: "2019-12-15",
      effectiveEndDate: "2020-12-15",
      defenceOrganisation: defence_organisation,
    }
  end

  before do
    allow(connection)
      .to receive(:post)
      .and_return(Faraday::Response.new(status: 202, body: { "test" => "test" }))
  end

  it "makes a post request" do
    expected_url = "prosecutionCases/representationOrder/applications/#{court_application.id}/subject/#{subject_id}/offences/#{offence_id}"

    expect(connection)
      .to receive(:post)
      .with(
        expected_url,
        request_params,
      )

    record_representation_order
  end
end
