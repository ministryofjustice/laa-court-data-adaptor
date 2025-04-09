require "rails_helper"

RSpec.describe CommonPlatform::Api::RecordCourtApplicationLaaReference do
  subject(:record_reference) do
    described_class.call(
      application_id:,
      subject_id:,
      offence_id:,
      status_code: "ABCDEF",
      application_reference: maat_reference,
      status_date: "2019-12-12",
      connection:,
    )
  end

  let(:application_id) { court_application.id }
  let(:court_application) { CourtApplication.create!(body: { foo: :bar }) }
  let(:subject_id) { "2ecc9feb-9407-482f-b081-d9e5c8ba3ed3" }
  let(:offence_id) { "3f153786-f3cf-4311-bc0c-2d6f48af68a1" }
  let(:maat_reference) { 999_999 }
  let(:connection) { instance_double(Faraday::Connection) }
  let(:url) { "prosecutionCases/laaReference/applications/#{application_id}/subject/#{subject_id}/offences/#{offence_id}" }
  let(:defendant_offence) do
    CourtApplicationDefendantOffence.create!(court_application_id: application_id,
                                             defendant_id: subject_id,
                                             offence_id:,
                                             application_type: "appeal")
  end

  let(:request_params) do
    {
      statusCode: "ABCDEF",
      applicationReference: "999999",
      statusDate: "2019-12-12",
    }
  end

  before do
    defendant_offence
    allow(connection).to receive(:post)
      .and_return(Faraday::Response.new(status: 202, body: { "test" => "test" }))
  end

  it "makes a post request" do
    expect(connection).to receive(:post).with(url, request_params)
    record_reference
  end

  it "updates the database record for the offence" do
    record_reference
    defendant_offence.reload
    expect(defendant_offence.status_date).to eq "2019-12-12"
    expect(defendant_offence.rep_order_status).to eq "ABCDEF"
    expect(defendant_offence.response_status).to eq(202)
    expect(defendant_offence.response_body).to eq({ "test" => "test" })
  end
end
