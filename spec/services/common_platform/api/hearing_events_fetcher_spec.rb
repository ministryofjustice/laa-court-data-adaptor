# frozen_string_literal: true

RSpec.describe CommonPlatform::Api::HearingEventsFetcher do
  subject(:fetch_hearing_events) { described_class.call(hearing_id:, hearing_date:) }

  let(:hearing_id) { "4d01840d-5959-4539-a450-d39f57171036" }
  let(:hearing_date) { "2020-08-17" }

  it "returns the requested hearing info" do
    VCR.use_cassette("hearing_logs_fetcher/success") do
      expect(fetch_hearing_events.body["hearingId"]).to eq(hearing_id)
    end
  end

  context "with a incorrect key" do
    subject(:fetch_hearing_events) { described_class.call(hearing_id:, hearing_date:, connection:) }

    let(:connection) { CommonPlatform::Connection.instance.call }

    before do
      connection.headers["Ocp-Apim-Subscription-Key"] = "INCORRECT KEY"
    end

    it "returns an unauthorised response" do
      VCR.use_cassette("hearing_logs_fetcher/unauthorised") do
        expect(fetch_hearing_events.status).to eq(401)
      end
    end
  end

  context "with a connection" do
    subject(:fetch_hearing_events) { described_class.call(hearing_id:, hearing_date:, connection:) }

    let(:connection) { double("CommonPlatform::Connection") }
    let(:url) { "hearing/hearingLog" }
    let(:params) { { hearingId: hearing_id, date: hearing_date } }

    it "makes a get request" do
      expect(connection).to receive(:get).with(url, params)
      fetch_hearing_events
    end
  end
end
