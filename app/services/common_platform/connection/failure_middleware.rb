# frozen_string_literal: true

module CommonPlatform
  class Connection
    class FailureMiddleware < Faraday::Middleware
      def call(env)
        @app.call(env)
      rescue Faraday::ConnectionFailed => e
        # The response logger never runs when the connection itself fails, so
        # this is the only chance to record the failure.
        TaggedLogger.log_event(
          :error,
          "common_platform_connection_failed",
          service: "common_platform",
          http_method: env.method.to_s.upcase,
          endpoint: Connection.endpoint_for(env.url),
          url: Connection.filter_pii(env.url),
          error_class: e.class.name,
          error_message: e.message,
        )

        raise CommonPlatform::Api::Errors::FailedDependency, e
      end
    end
  end
end
