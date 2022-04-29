# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LaaCourtDataAdaptor
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.x.common_platform_url = ENV.fetch("COMMON_PLATFORM_URL")
    config.x.client_cert = ENV["SSL_CLIENT_CERT"]
    config.x.client_key = ENV["SSL_CLIENT_KEY"]
    config.x.aws.sqs_url_link = ENV["AWS_LINK_QUEUE_URL"]
    config.x.aws.sqs_url_unlink = ENV["AWS_UNLINK_QUEUE_URL"]
    config.x.aws.sqs_url_hearing_resulted = ENV["AWS_HEARING_RESULTED_QUEUE_URL"]
    config.x.aws.sqs_url_prosecution_concluded = ENV["AWS_PROSECUTION_CONCLUDED_QUEUE_URL"]
    config.x.maat_api.oauth_url = ENV["MAAT_API_OAUTH_URL"]
    config.x.maat_api.client_id = ENV["MAAT_API_CLIENT_ID"]
    config.x.maat_api.client_secret = ENV["MAAT_API_CLIENT_SECRET"]
    config.x.maat_api.api_url = ENV["MAAT_API_API_URL"]

    config.x.metrics_service_host = ENV.fetch("METRICS_SERVICE_HOST", "localhost")

    config.active_record.schema_format = :sql

    config.autoload_paths << config.root.join("lib")
  end
end
