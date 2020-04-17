# frozen_string_literal: true

RSpec.describe HearingFetcher do
  subject { described_class.call(hearing_id: hearing_id) }

  let(:hearing_id) { 'ab746921-d839-4867-bcf9-b41db8ebc852' }

  it 'returns the requested hearing info' do
    VCR.use_cassette('hearing_result_fetcher/success') do
      expect(subject.body['id']).to eq(hearing_id)
    end
  end

  context 'with a incorrect key' do
    subject { described_class.call(hearing_id: hearing_id, shared_key: 'INCORRECT KEY') }

    it 'returns an unauthorised response' do
      VCR.use_cassette('hearing_result_fetcher/unauthorised') do
        expect(subject.status).to eq(401)
      end
    end
  end

  context 'connection' do
    subject { described_class.call(hearing_id: hearing_id, shared_key: 'SECRET KEY', connection: connection) }

    let(:connection) { double('CommonPlatformConnection') }
    let(:url) { '/LAAGetHearingHttpTrigger' }
    let(:params) { { hearingId: hearing_id } }
    let(:headers) { { 'Ocp-Apim-Subscription-Key' => 'SECRET KEY' } }

    it 'makes a get request' do
      expect(connection).to receive(:get).with(url, params, headers)
      subject
    end
  end
end
