# frozen_string_literal: true

# Perform Sidekiq jobs immediately in development,
# so you don't have to run a separate process.
# You'll also benefit from code reloading.
if ENV["INLINE_SIDEKIQ"] == "true"
  raise "Sidekiq must be run using redis in production" unless Rails.env.development?

  require "sidekiq/testing"
  Sidekiq::Testing.inline!
end

require "prometheus_exporter/instrumentation"

unless Rails.env.test?
  Sidekiq.configure_server do |config|
    config.server_middleware do |chain|
      chain.add PrometheusExporter::Instrumentation::Sidekiq
    end
    config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler

    config.on :startup do
      PrometheusExporter::Instrumentation::SidekiqQueue.start # monitor Queue size and latency
      PrometheusExporter::Instrumentation::Process.start type: "sidekiq" # monitor Sidekiq process information
    end
  end
end
