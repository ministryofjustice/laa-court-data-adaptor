ActionDispatch::DebugExceptions.register_interceptor do |_req, exception|
  # Rails normally handles these errors itself so they are never exposed to
  # Sentry. However we want to be alerted whenever a system tries to reach
  # an endpoint that doesn't exist, BUT ONLY in environments where access
  # to the API is IP-restricted, so that we're not constantly alerted by
  # crawlers trying random paths.
  if exception.is_a?(ActionController::RoutingError) && ENV.fetch("ACCESS_IP_RESTRICTED", "false") == "true"
    Sentry.capture_exception(exception, hint: { ignore_exclusions: true })
  end
end
