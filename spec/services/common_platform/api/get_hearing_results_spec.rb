# frozen_string_literal: true

RSpec.describe CommonPlatform::Api::GetHearingResults do
  subject(:get_hearing_results) { described_class.call(hearing_id: hearing_id) }

  let(:hearing_id) { "ceb158e3-7171-40ce-915b-441e2c4e3f75" }
  let(:response) { OpenStruct.new(body: { "amazing_body" => true }, "status" => 200, "success?" => true) }

  before do
    Current.request_id = 123

    allow(CommonPlatform::Api::HearingFetcher)
      .to receive(:call)
      .with(hearing_id: hearing_id, sitting_day: nil)
      .and_return(response)
  end

  context "when getting results by hearing ID only" do
    it "calls HearingFetcher with hearing ID" do
      expect(CommonPlatform::Api::HearingFetcher)
        .to receive(:call)
        .with(hearing_id: hearing_id, sitting_day: nil)

      get_hearing_results
    end
  end

  context "when publish_to_queue is enabled" do
    subject(:get_hearing_results) { described_class.call(hearing_id: hearing_id, publish_to_queue: true) }

    it "publishes to the queue" do
      expect(HearingsCreatorWorker)
        .to receive(:perform_async)
        .with(123, response.body)

      get_hearing_results
    end
  end

  context "when getting results by hearing id and hearing date" do
    subject(:get_hearing_results) { described_class.call(hearing_id: hearing_id, sitting_day: sitting_day) }

    let(:hearing_id) { "ceb158e3-7171-40ce-915b-441e2c4e3f75" }
    let(:sitting_day) { "2021-05-20" }

    before do
      allow(CommonPlatform::Api::HearingFetcher).to receive(:call).with(hearing_id: hearing_id, sitting_day: sitting_day).and_return(response)
    end

    it "calls HearingFetcher with hearing ID and sitting day" do
      expect(CommonPlatform::Api::HearingFetcher)
        .to receive(:call)
        .with(hearing_id: hearing_id, sitting_day: sitting_day)

      get_hearing_results
    end
  end
end
