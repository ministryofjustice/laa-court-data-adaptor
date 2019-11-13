# frozen_string_literal: true

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :faraday
  c.configure_rspec_metadata!
  c.filter_sensitive_data('<COMMON_PLATFORM_URL>') { ENV['COMMON_PLATFORM_URL'] }
end
