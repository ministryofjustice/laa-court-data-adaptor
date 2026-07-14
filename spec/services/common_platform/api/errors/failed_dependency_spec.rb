# frozen_string_literal: true

RSpec.describe CommonPlatform::Api::Errors::FailedDependency do
  it "can be raised with a plain message" do
    error = described_class.new("Common Platform connection failed")

    expect(error.message).to eq("Common Platform connection failed")
    expect(error.codes).to eq([:common_platform_connection_failed])
  end

  describe ".from_response" do
    let(:response) { instance_double(Faraday::Response, status: 502, body: response_body) }
    let(:response_body) { "Bad Gateway" }

    it "includes the service name, status and body in the message" do
      error = described_class.from_response(service: "MyService", response:)

      expect(error).to be_a(described_class)
      expect(error.message).to eq("MyService - Unsuccessful response from Common Platform: status: 502, body: Bad Gateway")
    end

    it "appends the context when provided" do
      error = described_class.from_response(service: "MyService", response:, context: "posting LAA Reference")

      expect(error.message).to end_with("status: 502, body: Bad Gateway (posting LAA Reference)")
    end

    context "when Common Platform responds with an HTML error page" do
      let(:response_body) { "<html><body>Service unavailable</body></html>" }

      it "strips the HTML tags from the body" do
        error = described_class.from_response(service: "MyService", response:)

        expect(error.message).to eq("MyService - Unsuccessful response from Common Platform: status: 502, body: Service unavailable")
      end
    end

    context "when the body is very long" do
      let(:response_body) { "a" * 600 }

      it "truncates the body" do
        error = described_class.from_response(service: "MyService", response:)

        expect(error.message).to include("#{'a' * 497}...")
        expect(error.message).not_to include("a" * 501)
      end
    end

    context "when the body is nil" do
      let(:response_body) { nil }

      it "builds the message with an empty body" do
        error = described_class.from_response(service: "MyService", response:)

        expect(error.message).to eq("MyService - Unsuccessful response from Common Platform: status: 502, body: ")
      end
    end
  end
end
