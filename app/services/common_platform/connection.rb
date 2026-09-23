# frozen_string_literal: true

require "singleton"

module CommonPlatform
  class Connection
    include Singleton

    HOST = Rails.configuration.x.common_platform_url
    CLIENT_CERT = Rails.configuration.x.client_cert
    CLIENT_KEY = Rails.configuration.x.client_key

    UUID_PATTERN = /\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/

    # Puma and Sidekiq size their thread pools from
    # RAILS_MAX_THREADS, so the HTTP pool has to keep in line with them.
    MAX_THREADS = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
    # One connection per thread, so no thread ever waits for a free one,
    # plus 2 extras to cover connections being reopened after IDLE_TIMEOUT.
    POOL_SIZE = MAX_THREADS + 2
    OPEN_TIMEOUT = 5   # connect + TLS handshake only
    READ_TIMEOUT = 30  # cap on a slow Common Platform response
    WRITE_TIMEOUT = 10
    # Kept deliberately short so we close pooled connections before Common
    # Platform does. Reusing a socket the server has already hung up on raises
    # EOFError/ECONNRESET, which the adapter surfaces as Faraday::ConnectionFailed.
    IDLE_TIMEOUT = 5

    # Query string values that must never reach the logs.
    PII_FILTERS = {
      /(defendantFirstName=)([^&]+)/ => '\1[FILTERED]',
      /(defendantMiddleName=)([^&]+)/ => '\1[FILTERED]',
      /(defendantLastName=)([^&]+)/ => '\1[FILTERED]',
      /(defendantName=)([^&]+)/ => '\1[FILTERED]',
      /(defendantDOB=)([^&]+)/ => '\1[FILTERED]',
      /(defendantNINO=)([^&]+)/ => '\1[FILTERED]',
      /(defendantASN=)([^&]+)/ => '\1[FILTERED]',
    }.freeze

    class << self
      def filter_pii(value)
        PII_FILTERS.reduce(value.to_s) do |filtered, (pattern, replacement)|
          filtered.gsub(pattern, replacement)
        end
      end

      # Strips record identifiers out of the path so that OpenSearch can
      # aggregate failures by endpoint instead of by individual request.
      def endpoint_for(url)
        url.respond_to?(:path) ? url.path.to_s.gsub(UUID_PATTERN, ":id") : url.to_s
      end
    end

    def initialize
      @connection = Faraday.new HOST, options do |connection|
        # FailureMiddleware converts transport errors into FailedDependency, so
        # it has to sit outside :retry or connection failures are never retried.
        connection.use FailureMiddleware
        connection.request :retry, retry_options
        connection.request :json
        connection.response :logger, TaggedLogger, { headers: false, formatter: CommonPlatform::Connection::LogFormatter } do |logger|
          PII_FILTERS.each { |pattern, replacement| logger.filter(pattern, replacement) }
        end
        connection.response :json, content_type: "application/json"
        connection.response :json, content_type: "application/vnd.unifiedsearch.query.laa.cases+json"
        connection.response :json, content_type: "text/plain"
        connection.adapter :net_http_persistent, pool_size: POOL_SIZE do |http|
          http.idle_timeout = IDLE_TIMEOUT
        end
      end
    end

    def call
      @connection
    end

  private

    def headers
      { "Ocp-Apim-Subscription-Key" => ENV["SHARED_SECRET_KEY"] }
    end

    def options
      base = { headers:, request: request_timeouts }

      return base if CLIENT_CERT.blank?

      base.merge(
        ssl: {
          client_cert: OpenSSL::X509::Certificate.new(CLIENT_CERT),
          client_key: OpenSSL::PKey::RSA.new(CLIENT_KEY),
          ca_file: Rails.root.join("lib/ssl/ca.crt").to_s,
        },
      )
    end

    def request_timeouts
      {
        open_timeout: OPEN_TIMEOUT,
        read_timeout: READ_TIMEOUT,
        write_timeout: WRITE_TIMEOUT,
      }
    end

    def retry_options
      {
        retry_statuses: [409, 429, 500, 502, 504],
        max: 3,
        interval: 1,
        max_interval: 10,
        interval_randomness: 0.5,
        backoff_factor: 2,
        methods: Faraday::Retry::Middleware::IDEMPOTENT_METHODS + [:post],
        exceptions: Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [Faraday::ConnectionFailed, Faraday::ParsingError],
      }
    end
  end
end
