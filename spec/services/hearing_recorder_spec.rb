# frozen_string_literal: true

require "sidekiq/testing"

RSpec.describe HearingRecorder do
  subject(:record_hearing) { described_class.call(hearing_id: hearing_id, body: body, publish_to_queue: true) }

  let(:hearing_id) { "fa78c710-6a49-4276-bbb3-ad34c8d4e313" }
  let(:body) { JSON.parse(file_fixture("hearing/valid.json").read) }

  it "creates a Hearing" do
    expect {
      record_hearing
    }.to change(Hearing, :count).by(1)
  end

  it "returns the created Hearing" do
    expect(record_hearing).to be_a(Hearing)
  end

  it "saves the body on the Hearing" do
    expect(record_hearing.body).to eq(body.stringify_keys)
  end

  it "enqueues a HearingsCreatorWorker" do
    Sidekiq::Testing.fake! do
      Current.set(request_id: "XYZ") do
        expect(HearingsCreatorWorker).to receive(:perform_async).with("XYZ", hearing_id).and_call_original
        record_hearing
      end
    end
  end

  context "when publishing to queue is disabled" do
    subject(:record_hearing) { described_class.call(hearing_id: hearing_id, body: body, publish_to_queue: false) }

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
      expect(hearing.reload.body).to eq(body.stringify_keys)
    end
  end

  context "when the hearing body is invalid as per the hearing contract" do
    let(:body) { "invalid data" }

    it "does not create a new record" do
      expect {
        record_hearing
      }.to change(Hearing, :count).by(0)
    end

    it "does not update Hearing with new response" do
      hearing = Hearing.create!(body: { foo: "bar" })

      hearing_recorder = described_class.new(hearing_id: hearing.id,
                                             body: body,
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
    let(:body) { "<span>Clearly not a processable hearing body</span>" }

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
