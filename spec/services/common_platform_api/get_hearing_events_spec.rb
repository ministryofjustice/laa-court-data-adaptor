# frozen_string_literal: true

RSpec.describe CommonPlatformApi::GetHearingEvents do
  subject(:get_hearing_events) { described_class.call(hearing_id: hearing_id, hearing_date: hearing_date) }

  let(:hearing_id) { "ceb158e3-7171-40ce-915b-441e2c4e3f75" }
  let(:hearing_date) { "2020-04-30" }

  let(:response) { double(body: { amazing_body: true }.to_json, status: 200) }

  before do
    allow(HearingEventsFetcher).to receive(:call).with(hearing_id: hearing_id, hearing_date: hearing_date).and_return(response)
  end

  it "calls the HearingEventsRecorder service" do
    expect(HearingEventsRecorder).to receive(:call).with(hearing_id: hearing_id, hearing_date: hearing_date, body: response.body)
    get_hearing_events
  end

  context "when the body is blank" do
    let(:response) { double(body: {}, status: 200) }

    it "does not record the result" do
      expect(HearingEventsRecorder).not_to receive(:call)
      get_hearing_events
    end
  end

  context "when the status is a 404" do
    let(:response) { double(body: {}.to_json, status: 404) }

    it "does not record the result" do
      expect(HearingEventsRecorder).not_to receive(:call)
      get_hearing_events
    end
  end
end
