# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "bundler"
gem "rails", "~> 8.1"

# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma", "~> 7.1"
# Use Active Model has_secure_password
gem "bcrypt", "~> 3.1.18"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

gem "aws-sdk-sqs"
gem "csv"
gem "doorkeeper", "~> 5.8"
gem "dry-validation"
gem "faraday", "~> 2.14"
gem "faraday-net_http_persistent", "~> 2"
gem "faraday-retry", "~> 2.3"
gem "hmcts_common_platform", github: "ministryofjustice/hmcts_common_platform", tag: "v0.2.0"
gem "jbuilder", "~> 2.14"
gem "jsonapi-serializer"
gem "json-schema", git: "https://github.com/voxpupuli/json-schema", branch: "master", ref: "081dfc3"
gem "lograge", "~> 0.14.0"
gem "oauth2"
gem "ostruct"
gem "prmd"
gem "prometheus_exporter", "2.3.1"
gem "rswag-api"
gem "rswag-ui"
gem "sentry-rails", "~> 6.2.0"
gem "sentry-ruby", "~> 6.2.0"
gem "sentry-sidekiq", "~> 6.2.0"
gem "sidekiq", ">= 6.5.10", "< 9.0"

group :development, :test do
  gem "dotenv-rails"
  gem "pry-byebug"
  gem "pry-rails", "~> 0.3.11"
  gem "rswag-specs"
  gem "rubocop-govuk"
  gem "rubocop-performance"
  gem "vcr"
  gem "webmock"
end

group :development do
  gem "brakeman"
  gem "listen", ">= 3.0.5", "< 3.10"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.1.0"
end

group :test do
  gem "json-schema-rspec"
  gem "rspec_junit_formatter"
  gem "rspec-rails", "~> 8.0.2"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "sinatra", "~> 4.2.1"
end
