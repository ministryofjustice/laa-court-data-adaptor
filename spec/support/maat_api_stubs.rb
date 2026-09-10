# frozen_string_literal: true

module MaatApiStubs
  def stub_maat_api_token
    stub_request(:post, %r{/oauth2/token\z}).to_return(
      status: 200,
      body: { access_token: "fake-maat-api-token", expires_in: 3600, token_type: "Bearer" }.to_json,
      headers: { "Content-Type" => "application/json" },
    )
  end

  def stub_maat_search(fixture, status: 200, content_type: "application/json")
    stub_maat_api_token
    stub_request(:post, maat_search_url).to_return(
      status:,
      body: file_fixture("maat_api/search/#{fixture}.json").read,
      headers: { "Content-Type" => content_type },
    )
  end

  def stub_maat_validation(fixture, status: 200, content_type: "application/json")
    stub_maat_api_token
    stub_request(:post, maat_validation_url).to_return(
      status:,
      body: file_fixture("maat_api/validation/#{fixture}.json").read,
      headers: { "Content-Type" => content_type },
    )
  end

private

  def maat_validation_url
    "#{ENV['MAAT_API_API_URL']}/#{MaatApi::MaatReferenceValidator::URL}"
  end

  def maat_search_url
    "#{ENV['MAAT_API_API_URL']}/#{MaatApi::MaatApplicationSearcher::URL}"
  end
end

RSpec.configure { |config| config.include MaatApiStubs }
