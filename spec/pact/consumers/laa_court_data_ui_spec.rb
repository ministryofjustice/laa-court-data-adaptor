require "rspec/mocks"
require "pact/rspec"

include RSpec::Mocks::ExampleMethods
include WebMock::API
include MaatApiStubs

RSpec.describe "laa-court-data-ui pact", :pact, pact_entity: :provider do
  http_pact_provider "laa-court-data-adaptor", opts: {
    app: Rails.application,
    http_port: 9393,
    logger: Rails.logger,
    log_level: :info,
    fail_if_no_pacts_found: true,

    broker_url: ENV.fetch("PACT_BROKER_BASE_URL", nil),
    broker_username: ENV.fetch("PACT_BROKER_USERNAME", nil),
    broker_password: ENV.fetch("PACT_BROKER_PASSWORD", nil),
    publish_verification_results: true,
    provider_version: ENV.fetch("PROVIDER_VERSION", "latest"),
  }

  before_state_setup do
    token = instance_double(Doorkeeper::AccessToken, accessible?: true, acceptable?: true)
    allow(Doorkeeper::OAuth::Token).to receive(:authenticate).and_return(token)
    allow(ProsecutionCaseLinkValidator).to receive(:new).and_return(double(call: true))
  end

  provider_state "a MAAT ID that is already linked" do
    set_up do
      stub_maat_validation("already_linked_maat_reference", status: 400)
    end
  end

  provider_state "an invalid MAAT ID" do
    set_up do
      stub_maat_validation("invalid_maat_reference", status: 400)
    end
  end

  provider_state "a MAAT ID with no Common Platform data" do
    set_up do
      stub_maat_validation("no_common_platform_data", status: 400)
    end
  end
end
