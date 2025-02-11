# frozen_string_literal: true

RSpec.describe CommonPlatform::Api::HearingFetcher do
  context "when fetching result by hearing id only" do
    subject(:fetch_hearing) { described_class.call(hearing_id:, sitting_day: nil) }

    let(:hearing_id) { "4d01840d-5959-4539-a450-d39f57171036" }

    it "returns the requested hearing info" do
      VCR.use_cassette("hearing_result_fetcher/success") do
        expect(fetch_hearing.body["hearing"]["id"]).to eq(hearing_id)
      end
    end

    context "with a incorrect key" do
      subject(:fetch_hearing) { described_class.call(hearing_id:, sitting_day: nil, connection:) }

      let(:connection) { CommonPlatform::Connection.instance.call }

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
      subject(:fetch_hearing) { described_class.call(hearing_id:, sitting_day: nil, connection:) }

      let(:connection) { double("CommonPlatformConnection") }
      let(:url) { "hearing/results" }
      let(:params) { { hearingId: hearing_id } }

      it "makes a get request" do
        expect(connection).to receive(:get).with(url, params)
        fetch_hearing
      end
    end
  end

  context "when fetching result with hearing_id and hearing_day query params" do
    subject(:fetch_hearing) { described_class.call(hearing_id:, sitting_day:) }

    let(:hearing_id) { "4d01840d-5959-4539-a450-d39f57171036" }
    let(:sitting_day) { "2020-08-17" }

    let(:connection) { double("CommonPlatform::Connection") }
    let(:url) { "hearing/results" }
    let(:params) { { hearingId: hearing_id } }

    it "returns the requested hearing info" do
      VCR.use_cassette("hearing_result_fetcher/success_specified_sitting_day") do
        expect(fetch_hearing.body["hearing"]["id"]).to eq(hearing_id)
      end
    end

    it "returns the requested hearing date" do
      VCR.use_cassette("hearing_result_fetcher/success_specified_sitting_day") do
        expect(fetch_hearing.body["hearing"]["hearingDays"][0]["sittingDay"]).to eq("2020-08-17T09:01:01.001Z")
      end
    end

    context "with connection" do
      subject(:fetch_hearing) { described_class.call(hearing_id:, sitting_day:, connection:) }

      let(:connection) { double("CommonPlatformConnection") }
      let(:url) { "hearing/results" }
      let(:params) { { hearingId: hearing_id, sittingDay: sitting_day } }

      it "makes a get request" do
        expect(connection).to receive(:get).with(url, params)
        fetch_hearing
      end
    end
  end
end
