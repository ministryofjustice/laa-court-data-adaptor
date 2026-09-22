# frozen_string_literal: true

RSpec.describe CommonPlatform::Connection do
  subject(:connect_to_common_platform) { described_class.instance.call }

  before do
    stub_const("CommonPlatform::Connection::HOST", host)
    stub_const("CommonPlatform::Connection::CLIENT_CERT", client_cert)
    stub_const("CommonPlatform::Connection::CLIENT_KEY", client_key)
    described_class.instance_variable_set(:@singleton__instance__, nil)
  end

  let(:host) { "https://example.com" }
  let(:client_cert) { nil }
  let(:client_key) { nil }

  let(:request_options) do
    { headers: { "Ocp-Apim-Subscription-Key" => "super-secret-key" } }
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

    it "initiates a json request" do
      allow(Faraday).to receive(:new).and_yield(connection)

      retry_options = {
        retry_statuses: [409, 429, 500, 502, 504],
        max: 3,
        interval: 1,
        max_interval: 10,
        interval_randomness: 0.5,
        backoff_factor: 2,
        methods: %i[delete get head options put post],
        exceptions: Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [Faraday::ConnectionFailed, Faraday::ParsingError],
      }

      expect(connection).to receive(:request).with(:retry, retry_options)
      expect(connection).to receive(:request).with(:json)
      expect(connection).to receive(:use).with(CommonPlatform::Connection::FailureMiddleware)
      expect(connection).to receive(:response).with(:logger, TaggedLogger, { headers: false, formatter: CommonPlatform::Connection::LogFormatter })
      expect(connection).to receive(:response).with(:json, content_type: "application/json")
      expect(connection).to receive(:response).with(:json, content_type: "application/vnd.unifiedsearch.query.laa.cases+json")
      expect(connection).to receive(:response).with(:json, content_type: "text/plain")
      expect(connection).to receive(:adapter).with(:typhoeus)

      connect_to_common_platform
    end
  end
end
