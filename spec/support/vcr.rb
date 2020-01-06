# frozen_string_literal: true

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :faraday
  c.configure_rspec_metadata!
  c.filter_sensitive_data('<COMMON_PLATFORM_URL>') { ENV['COMMON_PLATFORM_URL'] }
  c.filter_sensitive_data('<SHARED_SECRET_KEY_HEARING>') { ENV['SHARED_SECRET_KEY_HEARING'] }
  c.filter_sensitive_data('<SHARED_SECRET_KEY_SEARCH_PROSECUTION_CASE>') { ENV['SHARED_SECRET_KEY_SEARCH_PROSECUTION_CASE'] }
end
