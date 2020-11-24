# frozen_string_literal: true

require "webmock/rspec"

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each, stub_case_search_with_urn: true) do
    stub_request(:get, "#{ENV['COMMON_PLATFORM_URL']}/prosecutionCases")
      .with(query: { prosecutionCaseReference: prosecution_case_reference })
      .to_return(
        status: 200,
        body: prosecution_cases_json,
        headers: { "Content-Type" => "application/vnd.unifiedsearch.query.laa.cases+json" },
      )
  end

  config.before(:each, stub_hearing_result: true) do
    stub_request(:get, "#{ENV['COMMON_PLATFORM_URL']}/hearing/results")
      .with(query: hash_including('hearingId'))
      .to_return(
        status: 200,
        body: hearing_json,
        headers: { "Content-Type" => "application/vnd.unifiedsearch.query.laa.cases+json" },
      )
  end
end
