# frozen_string_literal: true

module CommonPlatformApiStubs
  def stub_prosecution_case_search(query:, body:, status: 200)
    stub_request(:get, "#{ENV['COMMON_PLATFORM_URL']}/prosecutionCases")
      .with(query:)
      .to_return(
        status:,
        headers: { content_type: "application/json" },
        body:,
      )
  end
end

RSpec.configure { |config| config.include CommonPlatformApiStubs }
