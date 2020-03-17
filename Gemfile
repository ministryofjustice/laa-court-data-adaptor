# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.2'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.3'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'
gem 'doorkeeper', '~> 5.3'
gem 'dry-validation'
gem 'faraday_middleware'
gem 'fast_jsonapi'
gem 'jsonapi_parameters'
gem 'prmd'
gem 'versionist'

group :development, :test do
  gem 'dotenv-rails'
  gem 'json-schema'
  gem 'pry-byebug'
  gem 'pry-rails', '~> 0.3.9'
  gem 'rspec-rails', '~> 4.0.0.rc1'
  gem 'rswag'
  gem 'rubocop', '~> 0.80.1', require: false
  gem 'rubocop-performance'
  gem 'vcr'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'rspec_junit_formatter'
  gem 'shoulda-matchers'
  gem 'simplecov'
end
