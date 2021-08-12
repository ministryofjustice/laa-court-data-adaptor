# frozen_string_literal: true

RSpec.describe CommonPlatformApi::CommonPlatformConnection do
  subject(:connect_to_common_platform) { described_class.call(host: host) }

  let(:host) { "https://example.com" }
  let(:request_options) do
    { headers: { "Ocp-Apim-Subscription-Key" => "super-secret-key" } }
  end

  let(:client_cert) { nil }
  let(:client_key) { nil }

  before do
    allow(Rails.configuration.x).to receive(:client_cert).and_return(client_cert)
    allow(Rails.configuration.x).to receive(:client_key).and_return(client_key)
  end

  it "connects to the common platform url" do
    expect(Faraday).to receive(:new).with(host, request_options)
    connect_to_common_platform
  end

  context "when a certificate and key is provided" do
    let(:client_cert) { "CERT" }
    let(:client_key) { "KEY" }
    let(:request_options) do
      {
        headers: {
          "Ocp-Apim-Subscription-Key" => "super-secret-key",
        },
        ssl: {
          client_cert: "OPENSSL_CERT",
          client_key: "OPENSSL_KEY",
          ca_file: Rails.root.join("lib/ssl/ca.crt").to_s,
        },
      }
    end

    before do
      allow(OpenSSL::X509::Certificate).to receive(:new).with(client_cert).and_return("OPENSSL_CERT")
      allow(OpenSSL::PKey::RSA).to receive(:new).with(client_key).and_return("OPENSSL_KEY")
    end

    it "connects to the common platform url" do
      expect(Faraday).to receive(:new).with(host, request_options)
      connect_to_common_platform
    end
  end

  context "with faraday configuration" do
    let(:connection) { double }

    before do
      allow(Faraday).to receive(:new).and_yield(connection)
    end

    it "initiates a json request" do
      retry_options = {
        methods: %i[delete get head options put post],
        retry_statuses: [429],
      }

      expect(connection).to receive(:request).with(:retry, retry_options)
      expect(connection).to receive(:request).with(:json)
      expect(connection).to receive(:response).with(:logger, Rails.logger)
      expect(connection).to receive(:response).with(:json, content_type: "application/json")
      expect(connection).to receive(:response).with(:json, content_type: "application/vnd.unifiedsearch.query.laa.cases+json")
      expect(connection).to receive(:response).with(:json, content_type: "text/plain")
      expect(connection).to receive(:adapter).with(:net_http)

      connect_to_common_platform
    end
  end
end
