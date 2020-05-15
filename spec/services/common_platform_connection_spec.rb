# frozen_string_literal: true

RSpec.describe CommonPlatformConnection do
  let(:host) { 'https://example.com' }
  let(:ssl_options) { hash_including(:ssl) }

  subject { described_class.call(host: host) }

  it 'connects to the common platform url' do
    expect(Faraday).to receive(:new).with(host, ssl_options)
    subject
  end

  context 'faraday configuration' do
    let(:connection) { double }

    before do
      allow(Faraday).to receive(:new).and_yield(connection)
    end

    it 'initiates a json request' do
      expect(connection).to receive(:request).with(:json)
      expect(connection).to receive(:response).with(:json, content_type: 'application/json')
      expect(connection).to receive(:response).with(:json, content_type: 'application/vnd.unifiedsearch.query.laa.cases+json')
      expect(connection).to receive(:response).with(:json, content_type: 'text/plain')
      expect(connection).to receive(:adapter).with(:net_http)
      subject
    end
  end
end
