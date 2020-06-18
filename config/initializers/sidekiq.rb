# frozen_string_literal: true

# Perform Sidekiq jobs immediately in development,
# so you don't have to run a separate process.
# You'll also benefit from code reloading.
if ENV['INLINE_SIDEKIQ'] == 'true'
  raise 'Sidekiq must be run using redis in production' unless Rails.env.development?

  require 'sidekiq/testing'
  Sidekiq::Testing.inline!
end
