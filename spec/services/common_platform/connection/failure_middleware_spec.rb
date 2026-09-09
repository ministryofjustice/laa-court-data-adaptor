# frozen_string_literal: true

RSpec.describe CommonPlatform::Connection::FailureMiddleware do
  subject(:test_connection) do
    Faraday.new("https://example.com") do |connection|
      connection.use described_class
      connection.adapter :test do |stub|
        stub.get("/search?defendantName=John") { raise Faraday::ConnectionFailed, "connection refused" }
      end
    end
  end

  it "logs connection failures events with structured fields before raising" do
    expect(TaggedLogger).to receive(:log_event) do |level, event, **fields|
      expect(level).to eq(:error)
      expect(event).to eq("common_platform_connection_failed")
      expect(fields).to include(
        service: "common_platform",
        http_method: "GET",
        endpoint: "/search",
        url: "https://example.com/search?defendantName=[FILTERED]",
        error_class: "Faraday::ConnectionFailed",
        error_message: "connection refused",
      )
    end

    expect { test_connection.get("/search?defendantName=John") }
      .to raise_error(CommonPlatform::Api::Errors::FailedDependency)
  end
end
