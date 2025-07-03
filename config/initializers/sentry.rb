if ENV["SENTRY_DSN"].present?
  EXCLUDE_PATHS = %w[/ping /ping.json /status /status.json].freeze
  Sentry.init do |config|
    config.environment = ENV.fetch("HOST_ENV", "local")
    config.dsn = ENV["SENTRY_DSN"]
    config.breadcrumbs_logger = [:active_support_logger]

    config.traces_sampler = lambda do |sampling_context|
      transaction_context = sampling_context[:transaction_context]
      transaction_name = transaction_context[:name]

      # Set traces_sample_rate to capture 5% of all traffic except
      # for things like liveness probes (which K8s does every few
      # seconds for every pod, so generate an inordinate amount of
      # traffic)
      transaction_name.in?(EXCLUDE_PATHS) ? 0.0 : 0.05
    end
  end
end
