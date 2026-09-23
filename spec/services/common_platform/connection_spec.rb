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
    {
      headers: { "Ocp-Apim-Subscription-Key" => "super-secret-key" },
      request: { open_timeout: 5, read_timeout: 30, write_timeout: 10 },
    }
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
        request: { open_timeout: 5, read_timeout: 30, write_timeout: 10 },
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

      expect(connection).to receive(:use).with(CommonPlatform::Connection::FailureMiddleware).ordered
      expect(connection).to receive(:request).with(:retry, retry_options).ordered
      expect(connection).to receive(:request).with(:json)
      expect(connection).to receive(:response).with(:logger, TaggedLogger, { headers: false, formatter: CommonPlatform::Connection::LogFormatter })
      expect(connection).to receive(:response).with(:json, content_type: "application/json")
      expect(connection).to receive(:response).with(:json, content_type: "application/vnd.unifiedsearch.query.laa.cases+json")
      expect(connection).to receive(:response).with(:json, content_type: "text/plain")
      expect(connection).to receive(:adapter).with(:net_http_persistent, pool_size: described_class::POOL_SIZE)

      connect_to_common_platform
    end
  end

  describe "failed connection settings" do
    let(:host) { "https://example.com" }

    describe "timeouts" do
      it "applies them to the Net::HTTP::Persistent connection" do
        adapter = connect_to_common_platform.builder.adapter.build(nil)
        env = Faraday::Env.new
        env[:url] = URI(host)
        env[:request] = connect_to_common_platform.options
        env[:ssl] = Faraday::SSLOptions.new

        http = adapter.send(:build_connection, env)

        expect(http.open_timeout).to eq(5)
        expect(http.read_timeout).to eq(30)
        expect(http.write_timeout).to eq(10)
        expect(http.idle_timeout).to eq(5)
      end
    end

    describe "connection pool" do
      it "is at least as large as the thread pool it serves" do
        expect(described_class::POOL_SIZE).to be > described_class::MAX_THREADS
      end
    end

    describe "retries" do
      it "retries connection failures before raising an error" do
        attempts = 0
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.get("/anything") do
            attempts += 1
            raise Faraday::ConnectionFailed, "rush hour"
          end
        end

        # Stubbing here so the example does not actually sleep around 7 seconds
        allow(Faraday::Retry::Middleware).to receive(:new).and_wrap_original do |original, *args, **kwargs, &blk|
          original.call(*args, **kwargs, &blk).tap { |middleware| allow(middleware).to receive(:sleep) }
        end

        connection = connect_to_common_platform
        connection.builder.adapter(:test, stubs)

        expect { connection.get("/anything") }.to raise_error(CommonPlatform::Api::Errors::FailedDependency)
        expect(attempts).to eq(4)
      end
    end
  end
end
