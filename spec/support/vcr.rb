# frozen_string_literal: true

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.debug_logger = File.open("log/vcr.log", "w") if ENV["VCR_DEBUG"]
  c.configure_rspec_metadata!
  c.filter_sensitive_data("<COMMON_PLATFORM_URL>") { ENV["COMMON_PLATFORM_URL"] }
  c.filter_sensitive_data("<SHARED_SECRET_KEY>") { ENV["SHARED_SECRET_KEY"] }
  c.filter_sensitive_data("<AUTH>", :maat_api) { |interaction| interaction.request.headers["Authorization"].first }
  c.filter_sensitive_data("<access_token>", :maat_api) do |interaction|
    JSON.parse(interaction.response.body)["access_token"] if interaction.response.headers["content-type"] == ["application/json;charset=UTF-8"]
  end
end
