# frozen_string_literal: true

RSpec.describe HearingFetcher do
  subject { described_class.call(hearing_id: hearing_id) }

  let(:hearing_id) { 'b935a64a-6d03-4da4-bba6-4d32cc2e7fb4' }

  it 'returns the requested hearing info' do
    VCR.use_cassette('hearing_result_fetcher/success') do
      expect(subject.body['id']).to eq(hearing_id)
    end
  end

  context 'with a incorrect key' do
    let(:connection) { CommonPlatformConnection.call }

    subject { described_class.call(hearing_id: hearing_id, connection: connection) }

    before do
      connection.headers['Ocp-Apim-Subscription-Key'] = 'INCORRECT KEY'
    end

    it 'returns an unauthorised response' do
      VCR.use_cassette('hearing_result_fetcher/unauthorised') do
        expect(subject.status).to eq(401)
      end
    end
  end

  context 'connection' do
    subject { described_class.call(hearing_id: hearing_id, connection: connection) }

    let(:connection) { double('CommonPlatformConnection') }
    let(:url) { 'LAAGetHearingHttpTrigger' }
    let(:params) { { hearingId: hearing_id } }

    it 'makes a get request' do
      expect(connection).to receive(:get).with(url, params)
      subject
    end
  end
end
