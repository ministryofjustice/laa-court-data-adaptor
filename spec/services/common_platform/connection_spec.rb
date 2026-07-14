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
        methods: %i[delete get head options put post],
        interval: 3,
        retry_statuses: [429],
      }

      expect(connection).to receive(:request).with(:retry, retry_options)
      expect(connection).to receive(:request).with(:json)
      expect(connection).to receive(:use).with(CommonPlatform::Connection::FailureMiddleware)
      expect(connection).to receive(:use).with(CommonPlatform::Connection::ErrorLoggingMiddleware)
      expect(connection).to receive(:response).with(:logger, TaggedLogger, { headers: false, formatter: CommonPlatform::Connection::LogFormatter })
      expect(connection).to receive(:response).with(:json, content_type: "application/json")
      expect(connection).to receive(:response).with(:json, content_type: "application/vnd.unifiedsearch.query.laa.cases+json")
      expect(connection).to receive(:response).with(:json, content_type: "text/plain")
      expect(connection).to receive(:adapter).with(:net_http_persistent, {
        idle_timeout: 120,
        keep_alive: 60,
        pool_size: 10,
        read_timeout: 30,
      })

      connect_to_common_platform
    end
  end

  describe CommonPlatform::Connection::LogFormatter do
    subject(:test_connection) do
      Faraday.new("https://example.com") do |connection|
        connection.response :logger, TaggedLogger, { headers: false, formatter: described_class } do |logger|
          logger.filter(/(defendantName=)([^&]+)/, '\1[FILTERED]')
        end
        connection.adapter :test do |stub|
          stub.get("/search?defendantName=John") { [200, {}, "all good"] }
        end
      end
    end

    it "logs the request and response with a Common Platform prefix, filtering PII" do
      expect(TaggedLogger).to receive(:info) do |&block|
        expect(block.call).to eq("Common Platform request: GET https://example.com/search?defendantName=[FILTERED]")
      end
      expect(TaggedLogger).to receive(:info) do |&block|
        expect(block.call).to eq("Common Platform response: Status 200")
      end

      test_connection.get("/search?defendantName=John")
    end
  end

  describe CommonPlatform::Connection::ErrorLoggingMiddleware do
    subject(:test_connection) do
      Faraday.new("https://example.com") do |connection|
        connection.use described_class
        connection.adapter :test do |stub|
          stub.get("/success") { [200, {}, "all good"] }
          stub.get("/failure") { [500, {}, "Internal Server Error"] }
          stub.get("/failure-with-long-body") { [502, {}, "a" * 600] }
          stub.get("/search?defendantName=John&defendantDOB=1990-01-01&defendantNINO=AB123456C&page=1") { [403, {}, "Forbidden"] }
        end
      end
    end

    it "does not log successful responses" do
      expect(TaggedLogger).not_to receive(:error)

      test_connection.get("/success")
    end

    it "logs the method, url, status and body of unsuccessful responses" do
      expect(TaggedLogger).to receive(:error).with(
        "Common Platform request failed: GET https://example.com/failure status: 500, body: Internal Server Error",
      )

      test_connection.get("/failure")
    end

    it "truncates long response bodies" do
      expect(TaggedLogger).to receive(:error).with(/body: a{497}\.\.\.\z/)

      test_connection.get("/failure-with-long-body")
    end

    it "filters defendant PII from the url" do
      expect(TaggedLogger).to receive(:error).with(
        "Common Platform request failed: GET https://example.com/search?defendantDOB=[FILTERED]&defendantNINO=[FILTERED]&defendantName=[FILTERED]&page=1 status: 403, body: Forbidden",
      )

      test_connection.get("/search?defendantName=John&defendantDOB=1990-01-01&defendantNINO=AB123456C&page=1")
    end
  end
end
