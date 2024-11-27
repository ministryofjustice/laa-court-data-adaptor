# frozen_string_literal: true

RSpec.describe CommonPlatform::Api::RecordRepresentationOrder do
  subject(:record_representation_order) do
    described_class.call(
      case_defendant_offence:,
      defendant_id:,
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

  let(:prosecution_case) { ProsecutionCase.create!(id: "5edd67eb-9d8c-44f2-a57e-c8d026defaa4", body: "{}") }
  let(:defendant_id) { "2ecc9feb-9407-482f-b081-d9e5c8ba3ed3" }
  let(:offence_id) { "3f153786-f3cf-4311-bc0c-2d6f48af68a1" }
  let(:connection) { double("CommonPlatform::Connection") }
  let(:defence_organisation) do
    {
      "organisation" => {
        "name" => "SOME ORGANISATION",
      },
      "laaContractNumber" => "CONTRACT REFERENCE",
    }
  end

  let!(:case_defendant_offence) do
    ProsecutionCaseDefendantOffence.create!(prosecution_case_id: prosecution_case.id,
                                            defendant_id:,
                                            offence_id:)
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
    expected_url = "prosecutionCases/representationOrder/cases/#{prosecution_case.id}/defendants/#{defendant_id}/offences/#{offence_id}"

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
    case_defendant_offence.reload
    expect(case_defendant_offence.status_date).to eq "2019-12-12"
    expect(case_defendant_offence.effective_start_date).to eq "2019-12-15"
    expect(case_defendant_offence.effective_end_date).to eq "2020-12-15"
    expect(case_defendant_offence.defence_organisation).to eq defence_organisation
    expect(case_defendant_offence.rep_order_status).to eq "ABCDEF"
    expect(case_defendant_offence.response_status).to eq(202)
    expect(case_defendant_offence.response_body).to eq({ "test" => "test" })
  end
end
