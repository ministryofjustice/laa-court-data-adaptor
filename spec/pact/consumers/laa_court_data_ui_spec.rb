require "rspec/mocks"
require "pact/rspec"

include RSpec::Mocks::ExampleMethods
include WebMock::API
include MaatApiStubs
include CommonPlatformApiStubs

RSpec.describe "laa-court-data-ui pact", :pact, pact_entity: :provider do
  http_pact_provider "laa-court-data-adaptor", opts: {
    app: Rails.application,
    http_port: 9393,
    logger: Rails.logger,
    log_level: :info,
    pact_dir: "spec/pacts",
    fail_if_no_pacts_found: true,

    broker_url: ENV.fetch("PACT_BROKER_BASE_URL", nil),
    broker_username: ENV.fetch("PACT_BROKER_USERNAME", nil),
    broker_password: ENV.fetch("PACT_BROKER_PASSWORD", nil),
    publish_verification_results: true,
    provider_version: ENV.fetch("PROVIDER_VERSION", "latest"),
    consumer_version_selectors: if ENV.fetch("CONSUMER_BRANCH", nil)
                                  [{ consumer: "laa-court-data-ui", branch: ENV.fetch("CONSUMER_BRANCH") }]
                                end,
  }

  before_state_setup do
    WebMock.reset!
    WebMock.disable_net_connect!(allow_localhost: true)
    token = instance_double(Doorkeeper::AccessToken, accessible?: true, acceptable?: true)
    allow(Doorkeeper::OAuth::Token).to receive(:authenticate).and_return(token)
    allow(ProsecutionCaseLinkValidator).to receive(:new).and_return(double(call: true))
  end

  after_state_teardown do
    WebMock.reset!
  end

  search_queries = [
    { prosecutionCaseReference: "TEST12345" },
    { defendantASN: "OC22ZJATX15T" },
    { defendantName: "Maxie Raynor", defendantDOB: "1973-06-30" },
    { defendantNINO: "YE744478B" },
  ]

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

  provider_state "a valid MAAT ID and defendant" do
    set_up do
      stub_maat_validation("valid_maat_reference", status: 200)
    end
  end

  provider_state "a request to link a defendant successfully" do
    set_up do
      stub_maat_validation("valid_maat_reference", status: 200)
      allow(ProsecutionCaseMaatLinkCreator).to receive(:call).and_return(true)
    end
  end

  [
    "no prosecution case exists",
    "no prosecution case matches the URN",
  ].each do |state|
    provider_state state do
      set_up do
        search_queries.each do |query|
          stub_prosecution_case_search(
            query:,
            body: { totalResults: 0, cases: [] }.to_json,
          )
        end
      end
    end
  end

  [
    "a prosecution case exists",
    "a defendant exists",
    "a prosecution case exists for a URN",
    "a prosecution case exists for an ASN",
    "a prosecution case exists for a national insurance number",
  ].each do |state|
    provider_state state do
      set_up do
        search_queries.each do |query|
          stub_prosecution_case_search(
            query:,
            body: Rails.root.join("spec/fixtures/files/pact/prosecution_case_search.json").read,
          )
        end
      end
    end
  end
end
