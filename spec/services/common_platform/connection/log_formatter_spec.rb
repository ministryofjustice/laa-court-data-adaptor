# frozen_string_literal: true

RSpec.describe CommonPlatform::Connection::LogFormatter do
  subject(:test_connection) do
    Faraday.new("https://example.com") do |connection|
      connection.response :logger, TaggedLogger, { headers: false, formatter: described_class } do |logger|
        logger.filter(/(defendantName=)([^&]+)/, '\1[FILTERED]')
      end
      connection.adapter :test do |stub|
        stub.get("/search?defendantName=John") { [200, {}, "all good"] }
        stub.get("/failure?defendantName=John") { [500, {}, "Internal Server Error"] }
        stub.get("/failure-with-long-body") { [502, {}, "a" * 600] }
        stub.get("/failure-with-html-body") { [504, {}, "<html><body><h1>Gateway Timeout</h1></body></html>"] }
        stub.get("/not-found") { [404, {}, "Not Found"] }
        stub.get("/hearing/ceb158e3-7171-40ce-915b-441e2c4e3f75/result") { [500, {}, "Internal Server Error"] }
      end
    end
  end

  it "logs the request and response with a Common Platform prefix and duration, filtering PII" do
    expect(TaggedLogger).not_to receive(:log_event)
    expect(TaggedLogger).to receive(:info) do |&block|
      expect(block.call).to eq("Common Platform request: GET https://example.com/search?defendantName=[FILTERED]")
    end
    expect(TaggedLogger).to receive(:info) do |&block|
      expect(block.call).to match(
        %r{\ACommon Platform response: GET https://example\.com/search\?defendantName=\[FILTERED\] status: 200 \(duration: \d+\.\d+s\)\z},
      )
    end

    test_connection.get("/search?defendantName=John")
  end

  it "logs unsuccessful responses as events with structured fields, filtering PII" do
    allow(TaggedLogger).to receive(:info)

    expect(TaggedLogger).to receive(:log_event) do |level, event, **fields|
      expect(level).to eq(:error)
      expect(event).to eq("common_platform_request_failed")
      expect(fields).to include(
        service: "common_platform",
        http_method: "GET",
        endpoint: "/failure",
        url: "https://example.com/failure?defendantName=[FILTERED]",
        status: 500,
        error_message: "Internal Server Error",
      )
      expect(fields[:duration_ms]).to be_a(Integer)
    end

    test_connection.get("/failure?defendantName=John")
  end

  it "replaces record identifiers in the endpoint so failures can be aggregated" do
    allow(TaggedLogger).to receive(:info)

    expect(TaggedLogger).to receive(:log_event) do |_level, _event, **fields|
      expect(fields[:endpoint]).to eq("/hearing/:id/result")
    end

    test_connection.get("/hearing/ceb158e3-7171-40ce-915b-441e2c4e3f75/result")
  end

  it "strips markup from HTML error pages" do
    allow(TaggedLogger).to receive(:info)

    expect(TaggedLogger).to receive(:log_event) do |_level, _event, **fields|
      expect(fields[:error_message]).to eq("Gateway Timeout")
    end

    test_connection.get("/failure-with-html-body")
  end

  it "logs statuses that Common Platform returns routinely at warn level" do
    allow(TaggedLogger).to receive(:info)

    expect(TaggedLogger).to receive(:log_event) do |level, _event, **fields|
      expect(level).to eq(:warn)
      expect(fields[:status]).to eq(404)
    end

    test_connection.get("/not-found")
  end

  it "truncates long response bodies" do
    allow(TaggedLogger).to receive(:info)

    expect(TaggedLogger).to receive(:log_event) do |_level, _event, **fields|
      expect(fields[:error_message]).to eq("#{'a' * 497}...")
    end

    test_connection.get("/failure-with-long-body")
  end
end
