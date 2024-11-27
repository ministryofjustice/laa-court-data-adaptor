# frozen_string_literal: true

RSpec.describe CommonPlatform::Api::GetHearingEvents do
  subject(:get_hearing_events) { described_class.call(hearing_id:, hearing_date:) }

  let(:hearing_id) { "ceb158e3-7171-40ce-915b-441e2c4e3f75" }
  let(:hearing_date) { "2020-04-30" }

  before do
    allow(CommonPlatform::Api::HearingEventsFetcher)
      .to receive(:call)
      .with(hearing_id:, hearing_date:)
      .and_return(response)
  end

  context "when the response is successful" do
    let(:response) { instance_double("Faraday::Response", body: { some: "data" }, status: 200) }

    it "returns an instance of HearingEventRecording" do
      expect(get_hearing_events).to be_a HearingEventRecording
    end
  end

  context "when the body is blank" do
    let(:response) { instance_double("Faraday::Response", body: {}, status: 200) }

    it "returns nil" do
      expect(get_hearing_events).to be_nil
    end
  end

  context "when the status is a 404" do
    let(:response) { instance_double("Faraday::Response", body: {}, status: 404) }

    it "returns nil" do
      expect(get_hearing_events).to be_nil
    end
  end
end
