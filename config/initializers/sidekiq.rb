# frozen_string_literal: true

require "sidekiq/web"

# Perform Sidekiq jobs immediately in development,
# so you don't have to run a separate process.
# You'll also benefit from code reloading.
if ENV["INLINE_SIDEKIQ"] == "true"
  raise "Sidekiq must be run using redis in production" unless Rails.env.development?

  require "sidekiq/testing"
  Sidekiq::Testing.inline!
end

Sidekiq.strict_args!

if Rails.env.production?
  Sidekiq.configure_server do |config|
    require "sidekiq/api"
    require "prometheus_exporter/instrumentation"
    config.server_middleware do |chain|
      chain.add PrometheusExporter::Instrumentation::Sidekiq
    end
    config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler
    config.on :startup do
      PrometheusExporter::Instrumentation::Process.start type: "sidekiq"
      PrometheusExporter::Instrumentation::SidekiqProcess.start
      PrometheusExporter::Instrumentation::SidekiqQueue.start
      PrometheusExporter::Instrumentation::SidekiqStats.start
    end
  end
end

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  ActiveSupport::SecurityUtils.secure_compare(
    ::Digest::SHA256.hexdigest(user), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_UI_USERNAME"])
  ) && ActiveSupport::SecurityUtils.secure_compare(
    ::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_UI_PASSWORD"])
  )
end
