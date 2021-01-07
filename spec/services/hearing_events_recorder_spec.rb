# frozen_string_literal: true

RSpec.describe HearingEventsRecorder do
  subject(:record_hearing_events) { described_class.call(hearing_id: hearing_id, hearing_date: hearing_date, body: body) }

  let(:hearing_id) { "fa78c710-6a49-4276-bbb3-ad34c8d4e313" }
  let(:hearing_date) { "2020-04-30" }
  let(:body) { { response: "text" }.to_json }

  it "creates a HearingEventRecording" do
    expect {
      record_hearing_events
    }.to change(HearingEventRecording, :count).by(1)
  end

  it "returns the created HearingEventRecording" do
    expect(record_hearing_events).to be_a(HearingEventRecording)
  end

  it "saves the body on the HearingEventRecording" do
    expect(record_hearing_events.body).to eq(body)
  end

  context "when the HearingEventRecording exists" do
    let!(:hearing_event_recording) { HearingEventRecording.create!(hearing_id: hearing_id, hearing_date: hearing_date, body: { amazing_body: true }) }

    it "does not create a new record" do
      expect {
        record_hearing_events
      }.to change(HearingEventRecording, :count).by(0)
    end

    it "updates HearingEventRecording with new response" do
      record_hearing_events
      expect(hearing_event_recording.reload.body).to eq(body)
    end
  end
end
