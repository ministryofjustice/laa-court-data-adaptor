# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HearingRecorder do
  subject { described_class.call(hearing_id) }

  let(:hearing_id) { 'fa78c710-6a49-4276-bbb3-ad34c8d4e313' }

  let(:response) { double(body: { hearing: { id: hearing_id } }.to_json) }

  before do
    allow(HearingFetcher).to receive(:call).and_return(response)
  end

  it 'creates a Hearing' do
    expect {
      subject
    }.to change(Hearing, :count).by(1)
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
      expect(hearing.reload.body).to eq(response.body)
    end
  end
end
