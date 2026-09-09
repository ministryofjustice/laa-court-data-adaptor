# frozen_string_literal: true

module CommonPlatform
  class Connection
    # All Common Platform logging lives here.
    # A request and a response line (with duration) for every call.
    class LogFormatter < Faraday::Logging::Formatter
      MAX_BODY_LENGTH = 500

      # Common Platform returns 404 for records it does not hold, and 429s are
      # absorbed by the retry middleware, so neither is an error on our side.
      EXPECTED_FAILURE_STATUSES = [404, 429].freeze

      def request(env)
        env[:started_at] = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        info { "Common Platform request: #{env.method.to_s.upcase} #{apply_filters(env.url.to_s)}" }
      end

      def response(env)
        duration = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - env[:started_at]).round(3)

        log_failure(env, duration) if env.status >= 400

        info do
          "Common Platform response: #{env.method.to_s.upcase} #{apply_filters(env.url.to_s)} " \
          "status: #{env.status} (duration: #{duration}s)"
        end
      end

    private

      def log_failure(env, duration)
        @logger.log_event(
          log_level_for(env.status),
          "common_platform_request_failed",
          service: "common_platform",
          http_method: env.method.to_s.upcase,
          endpoint: Connection.endpoint_for(env.url),
          url: apply_filters(env.url.to_s),
          status: env.status,
          error_message: error_message_for(env),
          duration_ms: (duration * 1000).round,
        )
      end

      def log_level_for(status)
        EXPECTED_FAILURE_STATUSES.include?(status) ? :warn : :error
      end

      def error_message_for(env)
        # In case of error, Common Platform API returns an HTML page.
        body = ActionView::Base.full_sanitizer.sanitize(env.body.to_s).strip

        apply_filters(body).truncate(MAX_BODY_LENGTH).presence
      end
    end
  end
end
