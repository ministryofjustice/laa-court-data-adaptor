# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.2"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.0.3"
# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma", "~> 5.1"
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
gem "doorkeeper", "~> 5.4"
gem "dry-validation"
gem "faraday_middleware"
gem "fast_jsonapi"
gem "hmcts_common_platform", github: "ministryofjustice/hmcts_common_platform", tag: "0.1.0"
gem "jsonapi_parameters"
gem "json-schema"
gem "oauth2"
gem "prmd"
gem "prometheus-client"
gem "rswag-api"
gem "rswag-ui"
gem "sentry-raven"
gem "sidekiq"
gem "versionist"

group :development, :test do
  gem "colorize"
  gem "dotenv-rails"
  gem "pry-byebug"
  gem "pry-rails", "~> 0.3.9"
  gem "rspec-rails", "~> 4.0.2"
  gem "rswag-specs"
  gem "rubocop-govuk"
  gem "rubocop-performance"
  gem "vcr"
  gem "webmock"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.4"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  gem "rspec_junit_formatter"
  gem "shoulda-matchers"
  gem "simplecov"
end
