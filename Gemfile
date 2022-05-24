# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.3"

gem "actionpack", "~> 6.1.5.1"
gem "actionview", "~> 6.1.5.1"
gem "activemodel", "~> 6.1.5.1"
gem "activerecord", "~> 6.1.5.1"
gem "activesupport", "~> 6.1.5.1"
gem "bundler"
gem "railties", "~> 6.1.5.1"

# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma", "~> 5.6"
# Use Active Model has_secure_password
gem "bcrypt", "~> 3.1.18"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

gem "aws-sdk-sqs"
gem "doorkeeper", "~> 5.5"
gem "dry-validation"
gem "faraday", "~> 2.3.0"
gem "faraday-retry"
gem "hmcts_common_platform", github: "ministryofjustice/hmcts_common_platform", tag: "v0.2.0"
gem "jbuilder", "~> 2.11"
gem "jsonapi_parameters"
gem "jsonapi-serializer"
gem "json-schema", git: "https://github.com/voxpupuli/json-schema", branch: "master", ref: "081dfc3"
gem "oauth2"
gem "prmd"
gem "prometheus_exporter", "2.0.3"
gem "rswag-api"
gem "rswag-ui"
gem "sentry-rails", "~> 5.3.1"
gem "sentry-ruby", "~> 5.3.1"
gem "sentry-sidekiq", "~> 5.3.1"
gem "sidekiq"
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
  gem "listen", ">= 3.0.5", "< 3.8"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  gem "json-schema-rspec"
  gem "rspec_junit_formatter"
  gem "rspec-rails", "~> 5.1.2"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "sinatra", "~> 2.2.0"
end
