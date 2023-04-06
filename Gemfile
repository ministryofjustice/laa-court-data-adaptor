# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.4"

gem "actionpack", "~> 7.0"
gem "actionview", "~> 7.0"
gem "activemodel", "~> 7.0"
gem "activerecord", "~> 7.0"
gem "activesupport", "~> 7.0"
gem "bundler"
gem "railties", "~> 7.0"

# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma", "~> 6.0"
# Use Active Model has_secure_password
gem "bcrypt", "~> 3.1.18"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

gem "aws-sdk-sqs"
gem "doorkeeper", "~> 5.6"
gem "dry-validation"
gem "faraday", "~> 2.7.4"
gem "faraday-retry", "~> 2.0.0"
gem "hmcts_common_platform", github: "ministryofjustice/hmcts_common_platform", tag: "v0.2.0"
gem "jbuilder", "~> 2.11", ">= 2.11.5"
gem "jsonapi_parameters"
gem "jsonapi-serializer"
gem "json-schema", git: "https://github.com/voxpupuli/json-schema", branch: "master", ref: "081dfc3"
gem "oauth2"
gem "prmd"
gem "prometheus_exporter", "2.0.8"
gem "rswag-api"
gem "rswag-ui"
gem "sentry-rails", "~> 5.7.0"
gem "sentry-ruby", "~> 5.7.0"
gem "sentry-sidekiq", "~> 5.7.0"
gem "sidekiq", "< 8.0"
gem "versionist"

group :development, :test do
  gem "dotenv-rails"
  gem "pry-byebug"
  gem "pry-rails", "~> 0.3.9"
  gem "rswag-specs"
  gem "rubocop-govuk"
  gem "rubocop-performance"
  gem "vcr"
  gem "webmock"
end

group :development do
  gem "brakeman"
  gem "listen", ">= 3.0.5", "< 3.9"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.1.0"
end

group :test do
  gem "json-schema-rspec"
  gem "rspec_junit_formatter"
  gem "rspec-rails", "~> 6.0.1"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "sinatra", "~> 3.0.5"
end
