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
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LaaCourtDataAdaptor
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.x.common_platform_url = ENV.fetch("COMMON_PLATFORM_URL")

    # The AWS secret squishes out line breaks from SSL certs, and our SSL lib expects at least
    # the BEGIN and END bits to be linebreaked, so we put them back in
    config.x.client_cert = ENV["SSL_CLIENT_CERT"].gsub("----- ", "-----\n").gsub(" -----", "\n-----")
    config.x.client_key = ENV["SSL_CLIENT_KEY"].gsub("----- ", "-----\n").gsub(" -----", "\n-----")

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

    config.session_store :cookie_store, key: "_interslice_session"
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use config.session_store, config.session_options
    config.active_support.to_time_preserves_timezone = :zone
  end
end
