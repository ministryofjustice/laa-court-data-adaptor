# frozen_string_literal: true

RSpec.describe HearingRecorder do
  let(:hearing_id) { 'fa78c710-6a49-4276-bbb3-ad34c8d4e313' }
  let(:body) { { 'response': 'text' } }
  let(:mock_hearings_creator_job) { double HearingsCreatorJob }

  before do
    allow(HearingsCreatorJob).to receive(:new).and_return(mock_hearings_creator_job)
    allow(mock_hearings_creator_job).to receive(:enqueue)
  end

  subject { described_class.call(hearing_id: hearing_id, body: body) }

  it 'creates a Hearing' do
    expect {
      subject
    }.to change(Hearing, :count).by(1)
  end

  it 'returns the created Hearing' do
    expect(subject).to be_a(Hearing)
  end

  it 'saves the body on the Hearing' do
    expect(subject.body).to eq(body.stringify_keys)
  end

  it 'creates a new HearingsCreatorJob' do
    expect(mock_hearings_creator_job).to receive(:enqueue)
    subject
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
      expect(hearing.reload.body).to eq(body.stringify_keys)
    end
  end
end
