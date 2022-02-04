# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.5"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# gem "rails", "~> 6.1.3"

# Remove dependency on Action Mailbox > Marcel > MimeMagic due to https://github.com/rails/rails/issues/41750,
# by loading only the individual Rails modules we need:
gem "actioncable"
gem "actionmailer"
gem "actionpack"
gem "actionview"
gem "activejob"
gem "activemodel"
gem "activerecord"
gem "activesupport"
gem "bundler"
gem "railties"

# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma", "~> 5.6"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
gem "bcrypt", "~> 3.1.16"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'
gem "aws-sdk-sqs"
gem "doorkeeper", "~> 5.5"
gem "dry-validation"
gem "faraday_middleware"
gem "hmcts_common_platform", github: "ministryofjustice/hmcts_common_platform", tag: "v0.2.0"
gem "jbuilder", "~> 2.11"
gem "jsonapi_parameters"
gem "jsonapi-serializer"
gem "json-schema"
gem "oauth2"
gem "prmd"
gem "prometheus_exporter"
gem "rswag-api"
gem "rswag-ui"
gem "sentry-rails", "~> 5.0.1"
gem "sentry-ruby", "~> 5.0.2"
gem "sentry-sidekiq", "~> 5.0.2"
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
  gem "rspec-rails", "~> 5.1.0"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "sinatra"
end
