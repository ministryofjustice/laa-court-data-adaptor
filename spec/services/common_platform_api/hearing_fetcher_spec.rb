# frozen_string_literal: true

RSpec.describe CommonPlatformApi::HearingFetcher do
  subject(:fetch_hearing) { described_class.call(hearing_id: hearing_id) }

  let(:hearing_id) { "4d01840d-5959-4539-a450-d39f57171036" }

  it "returns the requested hearing info" do
    VCR.use_cassette("hearing_result_fetcher/success") do
      expect(fetch_hearing.body["hearing"]["id"]).to eq(hearing_id)
    end
  end

  context "with a incorrect key" do
    subject(:fetch_hearing) { described_class.call(hearing_id: hearing_id, connection: connection) }

    let(:connection) { CommonPlatformApi::CommonPlatformConnection.call }

    before do
      connection.headers["Ocp-Apim-Subscription-Key"] = "INCORRECT KEY"
    end

    it "returns an unauthorised response" do
      VCR.use_cassette("hearing_result_fetcher/unauthorised") do
        expect(fetch_hearing.status).to eq(401)
      end
    end
  end

  context "with connection" do
    subject(:fetch_hearing) { described_class.call(hearing_id: hearing_id, connection: connection) }

    let(:connection) { double("CommonPlatformApi::CommonPlatformConnection") }
    let(:url) { "hearing/results" }
    let(:params) { { hearingId: hearing_id } }

    it "makes a get request" do
      expect(connection).to receive(:get).with(url, params)
      fetch_hearing
    end
  end
end
