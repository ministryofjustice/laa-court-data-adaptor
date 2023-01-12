if ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.sample_rate = 0.05
    config.dsn = ENV["SENTRY_DSN"]
    config.breadcrumbs_logger = [:active_support_logger]
  end
end
