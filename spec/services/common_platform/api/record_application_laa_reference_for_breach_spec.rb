require "rails_helper"

RSpec.describe CommonPlatform::Api::RecordApplicationLaaReferenceForBreach do
  subject(:record_reference) do
    described_class.call(
      application_id:,
      status_code: "ABCDEF",
      application_reference: maat_reference,
      status_date: "2019-12-12",
      connection:,
    )
  end

  let(:application_id) { court_application.id }
  let(:court_application) { CourtApplication.create!(body: { foo: :bar }) }
  let(:maat_reference) { 999_999 }
  let(:connection) { instance_double(Faraday::Connection) }
  let(:url) { "prosecutionCases/laaReference/applications/#{application_id}" }
  let(:request_params) do
    {
      statusCode: "ABCDEF",
      applicationReference: "999999",
      statusDate: "2019-12-12",
    }
  end

  before do
    allow(connection).to receive(:post)
      .and_return(Faraday::Response.new(status: 202, body: { "test" => "test" }))
  end

  it "makes a post request" do
    expect(connection).to receive(:post).with(url, request_params)
    record_reference
  end
end
