# frozen_string_literal: true

RSpec.describe HearingEventsRecorder do
  let(:hearing_id) { 'fa78c710-6a49-4276-bbb3-ad34c8d4e313' }
  let(:events) { { response: 'text' }.to_json }

  subject { described_class.call(hearing_id: hearing_id, events: events) }

  it 'creates a Hearing' do
    expect {
      subject
    }.to change(Hearing, :count).by(1)
  end

  it 'returns the created Hearing' do
    expect(subject).to be_a(Hearing)
  end

  it 'saves the events on the Hearing' do
    expect(subject.events).to eq(events)
  end

  context 'when the Hearing exists' do
    let!(:hearing) { Hearing.create!(id: hearing_id, body: { amazing_body: true }) }

    it 'does not create a new record' do
      expect {
        subject
      }.to change(Hearing, :count).by(0)
    end

    it 'updates Hearing with new response' do
      subject
      expect(hearing.reload.events).to eq(events)
    end
  end
end
