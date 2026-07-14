# frozen_string_literal: true

require "singleton"

module CommonPlatform
  class Connection
    include Singleton

    HOST = Rails.configuration.x.common_platform_url
    CLIENT_CERT = Rails.configuration.x.client_cert
    CLIENT_KEY = Rails.configuration.x.client_key

    def initialize
      @connection = Faraday.new HOST, options do |connection|
        connection.request :retry, retry_options
        connection.request :json
        connection.response :logger, TaggedLogger, { headers: false, formatter: LogFormatter } do |logger|
          logger.filter(/(defendantName=)([^&]+)/, '\1[FILTERED]')
          logger.filter(/(defendantDOB=)([^&]+)/, '\1[FILTERED]')
          logger.filter(/(defendantNINO=)([^&]+)/, '\1[FILTERED]')
        end
        connection.use FailureMiddleware
        connection.response :json, content_type: "application/json"
        connection.response :json, content_type: "application/vnd.unifiedsearch.query.laa.cases+json"
        connection.response :json, content_type: "text/plain"
        connection.adapter :net_http_persistent, {
          keep_alive: 60,
          pool_size: 10,    # to safetly handle For 3-5 req/sec
          idle_timeout: 120,
          read_timeout: 30, # 30 seconds: to have safe buffer for slow responses
        }
      end
    end

    def call
      @connection
    end

  private

    # All Common Platform logging lives here.
    # A request and a response line (with duration) for every call.
    class LogFormatter < Faraday::Logging::Formatter
      MAX_BODY_LENGTH = 500

      def request(env)
        env[:started_at] = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        info { "Common Platform request: #{env.method.to_s.upcase} #{apply_filters(env.url.to_s)}" }
      end

      def response(env)
        duration = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - env[:started_at]).round(3)

        if env.status >= 400
          error do
            "Common Platform request failed: #{env.method.to_s.upcase} #{apply_filters(env.url.to_s)} " \
            "status: #{env.status}, body: #{env.body.to_s.truncate(MAX_BODY_LENGTH)} (duration: #{duration}s)"
          end
        end

        info { "Common Platform response: Status #{env.status} (duration: #{duration}s)" }
      end
    end

    class FailureMiddleware < Faraday::Middleware
      def call(env)
        @app.call(env)
      rescue Faraday::ConnectionFailed => e
        raise CommonPlatform::Api::Errors::FailedDependency, e
      end
    end

    def headers
      { "Ocp-Apim-Subscription-Key" => ENV["SHARED_SECRET_KEY"] }
    end

    def options
      return { headers: } if CLIENT_CERT.blank?

      {
        headers:,
        ssl: {
          client_cert: OpenSSL::X509::Certificate.new(CLIENT_CERT),
          client_key: OpenSSL::PKey::RSA.new(CLIENT_KEY),
          ca_file: Rails.root.join("lib/ssl/ca.crt").to_s,
        },
      }
    end

    def retry_options
      {
        retry_statuses: [429],
        interval: 3,
        methods: %i[delete get head options put post],
      }
    end
  end
end
