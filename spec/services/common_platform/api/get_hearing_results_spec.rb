# frozen_string_literal: true

RSpec.describe CommonPlatform::Api::GetHearingResults do
  subject(:get_hearing_results) { described_class.call(hearing_id: hearing_id) }

  let(:hearing_id) { "ceb158e3-7171-40ce-915b-441e2c4e3f75" }

  let(:response) { double(body: { amazing_body: true }, status: 200) }

  before do
    allow(CommonPlatform::Api::HearingFetcher).to receive(:call).with(hearing_id: hearing_id).and_return(response)
  end

  it "calls the HearingRecorder service" do
    expect(HearingRecorder).to receive(:call).with(hearing_id: hearing_id, hearing_resulted_data: response.body, publish_to_queue: false)
    get_hearing_results
  end

  context "when publish_to_queue is enabled" do
    subject(:get_hearing_results) { described_class.call(hearing_id: hearing_id, publish_to_queue: true) }

    it "calls the HearingRecorder service" do
      expect(HearingRecorder).to receive(:call).with(hearing_id: hearing_id, hearing_resulted_data: response.body, publish_to_queue: true)
      get_hearing_results
    end
  end

  context "when the body is blank" do
    let(:response) { double(body: {}, status: 200) }

    it "does not record the result" do
      expect(HearingRecorder).not_to receive(:call)
      get_hearing_results
    end
  end

  context "when the status is a 404" do
    let(:response) { double(body: {}, status: 404) }

    it "does not record the result" do
      expect(HearingRecorder).not_to receive(:call)
      get_hearing_results
    end
  end
end
