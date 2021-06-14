# frozen_string_literal: true

require "sidekiq/testing"

RSpec.describe HearingRecorder do
  subject(:record_hearing) { described_class.call(hearing_id: hearing_id, hearing_resulted_data: hearing_resulted_data, publish_to_queue: true) }

  let(:hearing_id) { "fa78c710-6a49-4276-bbb3-ad34c8d4e313" }
  let(:hearing_resulted_data) { JSON.parse(file_fixture("hearing/valid.json").read) }

  it "creates a Hearing" do
    expect {
      record_hearing
    }.to change(Hearing, :count).by(1)
  end

  it "returns the created Hearing" do
    expect(record_hearing).to be_a(Hearing)
  end

  it "saves the hearing_resulted_data on the Hearing" do
    expect(record_hearing.body).to eq(hearing_resulted_data.stringify_keys)
  end

  it "enqueues a HearingsCreatorWorker" do
    Sidekiq::Testing.fake! do
      Current.set(request_id: "XYZ") do
        expect(HearingsCreatorWorker).to receive(:perform_async).with("XYZ", hearing_resulted_data).and_call_original
        record_hearing
      end
    end
  end

  context "when publishing to queue is disabled" do
    subject(:record_hearing) { described_class.call(hearing_id: hearing_id, hearing_resulted_data: hearing_resulted_data, publish_to_queue: false) }

    it "does not enqueue a HearingsCreatorWorker" do
      expect(HearingsCreatorWorker).not_to receive(:perform_async)
      record_hearing
    end
  end

  context "when the Hearing exists" do
    let!(:hearing) { Hearing.create!(id: hearing_id, body: { amazing_body: true }) }

    it "does not create a new record" do
      expect {
        record_hearing
      }.to change(Hearing, :count).by(0)
    end

    it "updates Hearing with new response" do
      record_hearing
      expect(hearing.reload.body).to eq(hearing_resulted_data.stringify_keys)
    end
  end

  context "when the hearing resulted data is invalid as per the hearing contract" do
    let(:hearing_resulted_data) { JSON.parse(file_fixture("hearing/invalid.json").read) }

    it "does not create a new record" do
      expect {
        record_hearing
      }.to change(Hearing, :count).by(0)
    end

    it "does not update Hearing with new response" do
      hearing = Hearing.create!(body: { foo: "bar" })
      hearing_resulted_data = JSON.parse(file_fixture("hearing/invalid.json").read)

      hearing_recorder = described_class.new(hearing_id: hearing.id,
                                             hearing_resulted_data: hearing_resulted_data,
                                             publish_to_queue: true)

      hearing_recorder.call

      expect(hearing.reload.body).to eq({ "foo" => "bar" })
    end

    it "does not publish hearing to the queue" do
      expect(HearingsCreatorWorker).not_to receive(:perform_async)
      record_hearing
    end
  end

  context "when the hearing body is jibberish" do
    let(:hearing) { Hearing.create!(body: { foo: "bar" }) }
    let(:hearing_resulted_data) { "<span>Clearly not a processable hearing body</span>" }

    it "reports exception to Sentry" do
      expect(Sentry).to receive(:capture_exception)
      record_hearing
    end

    it "does not create a new record" do
      expect {
        record_hearing
      }.to change(Hearing, :count).by(0)
    end

    it "does not update Hearing with new response" do
      record_hearing
      expect(hearing.reload.body).to eq({ "foo" => "bar" })
    end

    it "does not publish hearing to the queue" do
      expect(HearingsCreatorWorker).not_to receive(:perform_async)
    end
  end
end
