# frozen_string_literal: true

RSpec.describe CommonPlatform::Api::CourtApplicationRecordRepresentationOrder do
  subject(:record_representation_order) do
    described_class.call(
      court_application_defendant_offence:,
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

  let(:court_application) { CourtApplication.create!(id: "5edd67eb-9d8c-44f2-a57e-c8d026defaa4", body: "{}") }
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

  let!(:court_application_defendant_offence) do
    CourtApplicationDefendantOffence.create!(
      court_application_id: court_application.id,
      defendant_id: subject_id,
      offence_id: offence_id,
      application_type: "4567",
    )
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

  it "updates the database record for the offence" do
    record_representation_order
    court_application_defendant_offence.reload
    expect(court_application_defendant_offence.status_date).to eq "2019-12-12"
    expect(court_application_defendant_offence.effective_start_date).to eq "2019-12-15"
    expect(court_application_defendant_offence.effective_end_date).to eq "2020-12-15"
    expect(court_application_defendant_offence.defence_organisation).to eq defence_organisation
    expect(court_application_defendant_offence.rep_order_status).to eq "ABCDEF"
    expect(court_application_defendant_offence.response_status).to eq(202)
    expect(court_application_defendant_offence.response_body).to eq({ "test" => "test" })
  end
end
