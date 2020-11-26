# frozen_string_literal: true

RSpec.describe MaatApi::Connection do
  let(:host) { "https://example.com" }

  subject { described_class.call(host: host) }

  it "connects to the maat api url" do
    expect(Faraday).to receive(:new).with(host)
    subject
  end

  context "when the host is not defined" do
    let(:host) { nil }

    it "does not connect to the maat api url" do
      expect(Faraday).not_to receive(:new)
      subject
    end
  end

  context "faraday configuration" do
    let(:connection) { double }
    let(:oauth_client) { instance_double("OAuth2::Client", client_credentials: double(get_token: double(token: "TOKEN"))) }

    before do
      allow(Faraday).to receive(:new).and_yield(connection)
      allow(OAuth2::Client).to receive(:new).and_return(oauth_client)
    end

    it "initiates a json request" do
      expect(connection).to receive(:request).with(:oauth2, String, token_type: :bearer)
      expect(connection).to receive(:request).with(:json)
      expect(connection).to receive(:response).with(:json, content_type: "application/json")
      expect(connection).to receive(:adapter).with(:net_http)
      subject
    end
  end
end
