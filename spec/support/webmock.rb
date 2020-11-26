# frozen_string_literal: true

require "webmock/rspec"

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each, stub_case_search_with_urn: true) do
    stub_request(:get, %r{http.*/apigw.*\.cjscp\.org\.uk/LAA/v1/prosecutionCases\?prosecutionCaseReference=#{prosecution_case_reference}})
      .to_return(
        status: 200,
        body: prosecution_cases_json,
        headers: { "Content-Type" => "application/vnd.unifiedsearch.query.laa.cases+json" },
      )
  end

  config.before(:each, stub_hearing_result: true) do
    uuid_regex = /[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}/

    stub_request(:get, %r{http.*/apigw.*\.cjscp\.org\.uk/LAA/v1/hearing/results\?hearingId=#{uuid_regex}})
      .to_return(
        status: 200,
        body: hearing_json,
        headers: { "Content-Type" => "application/vnd.unifiedsearch.query.laa.cases+json" },
      )
  end
end
