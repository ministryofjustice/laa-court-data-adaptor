require "pact"
require "pact/rspec"

RSpec.shared_context "with laa-maat-court-data-api consumer pact" do
  has_http_pact_between "laa-court-data-adaptor", "laa-maat-court-data-api", opts: { pact_dir: "spec/pacts" }

  let(:connection) { MaatApi::Connection.new(host: mock_server.url).call }
  let(:mock_server) { @mock_server }

  before { stub_maat_api_token }

  around do |example|
    interaction.execute do |mock_server|
      @mock_server = mock_server
      example.run
    end
  end
end
