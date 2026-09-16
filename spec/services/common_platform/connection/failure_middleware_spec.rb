# frozen_string_literal: true

RSpec.describe CommonPlatform::Connection::FailureMiddleware do
  def build_connection(error_class, error_message)
    Faraday.new("https://example.com") do |connection|
      connection.use described_class
      connection.adapter :test do |stub|
        stub.get("/search?defendantName=John") { raise error_class, error_message }
      end
    end
  end

  [
    [Faraday::ConnectionFailed, "connection refused"],
    [Faraday::TimeoutError, "execution expired"],
    [Faraday::SSLError, "SSL certificate problem"],
  ].each do |error_class, error_message|
    context "when the connection raises #{error_class}" do
      subject(:test_connection) { build_connection(error_class, error_message) }

      it "logs connection failure events with structured fields before raising" do
        expect(TaggedLogger).to receive(:log_event) do |level, event, **fields|
          expect(level).to eq(:error)
          expect(event).to eq("common_platform_connection_failed")
          expect(fields).to include(
            service: "common_platform",
            http_method: "GET",
            endpoint: "/search",
            url: "https://example.com/search?defendantName=[FILTERED]",
            error_class: error_class.name,
            error_message:,
          )
        end

        expect { test_connection.get("/search?defendantName=John") }
          .to raise_error(CommonPlatform::Api::Errors::FailedDependency)
      end
    end
  end
end
