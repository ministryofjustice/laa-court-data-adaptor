# frozen_string_literal: true

RSpec.describe Api::GetHearingResults do
  subject { described_class.call(hearing_id: hearing_id) }

  let(:hearing_id) { 'ceb158e3-7171-40ce-915b-441e2c4e3f75' }

  let(:response) { double(body: { amazing_body: true }.to_json, status: 200) }

  before do
    allow(HearingFetcher).to receive(:call).with(hearing_id: hearing_id).and_return(response)
  end

  it 'calls the HearingRecorder service' do
    expect(HearingRecorder).to receive(:call).with(hearing_id: hearing_id, body: response.body)
    subject
  end

  context 'when the status is a 404' do
    let(:response) { double(body: {}.to_json, status: 404) }

    it 'does not record the result' do
      expect(HearingRecorder).not_to receive(:call)
      subject
    end
  end
end
