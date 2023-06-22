if ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.sample_rate = 0.05
    config.dsn = ENV["SENTRY_DSN"]
    config.breadcrumbs_logger = [:active_support_logger]

    # Approximately 5% of the transactions will get recorded by Sentry
    config.traces_sample_rate = 0.05
  end
end
