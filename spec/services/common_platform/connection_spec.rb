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
    let(:openssl_cert) { instance_double(OpenSSL::X509::Certificate, to_pem: "CERT_PEM") }
    let(:openssl_key) { instance_double(OpenSSL::PKey::RSA, to_pem: "KEY_PEM") }

    before do
      allow(OpenSSL::X509::Certificate).to receive(:new).with(client_cert).and_return(openssl_cert)
      allow(OpenSSL::PKey::RSA).to receive(:new).with(client_key).and_return(openssl_key)
    end

    it "connects to the common platform url" do
      expect(Faraday).to receive(:new) do |url, options|
        expect(url).to eq(host)
        expect(options[:headers]).to eq("Ocp-Apim-Subscription-Key" => "super-secret-key")
      end

      connect_to_common_platform
    end

    # Typhoeus requires file paths rather than OpenSSL objects
    it "writes the certificate and key to files readable only by the owner" do
      allow(Faraday).to receive(:new) do |_url, options|
        ssl = options[:ssl]

        expect(File.read(ssl[:client_cert])).to eq("CERT_PEM")
        expect(File.read(ssl[:client_key])).to eq("KEY_PEM")
        expect(sprintf("%o", File.stat(ssl[:client_cert]).mode & 0o777)).to eq("600")
        expect(sprintf("%o", File.stat(ssl[:client_key]).mode & 0o777)).to eq("600")
      end

      connect_to_common_platform
    end

    # Typhoeus replaces its trust store with the CA file it is given, so the system
    # roots that anchor the Common Platform chain have to be included alongside ours
    it "trusts the bundled CA certificate as well as the system CA certificates" do
      system_ca_file = Tempfile.new("system_ca")
      system_ca_file.write("SYSTEM_CA")
      system_ca_file.flush
      stub_const("OpenSSL::X509::DEFAULT_CERT_FILE", system_ca_file.path)

      allow(Faraday).to receive(:new) do |_url, options|
        ca_bundle = File.read(options[:ssl][:ca_file])

        expect(ca_bundle).to include(CommonPlatform::Connection::CA_CERT_PATH.read)
        expect(ca_bundle).to include("SYSTEM_CA")
      end

      connect_to_common_platform
    end

    it "omits the system CA directory when it does not exist" do
      stub_const("OpenSSL::X509::DEFAULT_CERT_DIR", "/does/not/exist")

      allow(Faraday).to receive(:new) do |_url, options|
        expect(options[:ssl]).not_to have_key(:ca_path)
      end

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
