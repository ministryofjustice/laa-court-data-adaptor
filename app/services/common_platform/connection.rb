# frozen_string_literal: true

require "singleton"

module CommonPlatform
  class Connection
    include Singleton

    HOST = Rails.configuration.x.common_platform_url
    CLIENT_CERT = Rails.configuration.x.client_cert
    CLIENT_KEY = Rails.configuration.x.client_key

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

    UUID_PATTERN = /\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/

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
        connection.request :retry, retry_options
        connection.request :json
        connection.response :logger, TaggedLogger, { headers: false, formatter: CommonPlatform::Connection::LogFormatter } do |logger|
          PII_FILTERS.each { |pattern, replacement| logger.filter(pattern, replacement) }
        end
        connection.use FailureMiddleware
        connection.response :json, content_type: "application/json"
        connection.response :json, content_type: "application/vnd.unifiedsearch.query.laa.cases+json"
        connection.response :json, content_type: "text/plain"
        connection.adapter :net_http_persistent, {
          keep_alive: 60,
          pool_size: 10,    # to safetly handle For 3-5 req/sec
          idle_timeout: 120,
          open_timeout: 3,  # connect + TLS only; without this Net::HTTP defaults to 60 seconds
          read_timeout: 10,
        }
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
