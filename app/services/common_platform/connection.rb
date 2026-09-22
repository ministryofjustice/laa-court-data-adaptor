# frozen_string_literal: true

require "singleton"
require "tempfile"

module CommonPlatform
  class Connection
    include Singleton

    HOST = Rails.configuration.x.common_platform_url
    CLIENT_CERT = Rails.configuration.x.client_cert
    CLIENT_KEY = Rails.configuration.x.client_key
    CA_CERT_PATH = Rails.root.join("lib/ssl/ca.crt")

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
      @ssl_files = []
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
        connection.adapter :typhoeus
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
          client_cert: ssl_file_path("client_cert", OpenSSL::X509::Certificate.new(CLIENT_CERT).to_pem),
          client_key: ssl_file_path("client_key", OpenSSL::PKey::RSA.new(CLIENT_KEY).to_pem),
          ca_file: ca_bundle_path,
          ca_path: system_ca_dir,
        }.compact,
      }
    end

    # Typhoeus requires file paths rather than OpenSSL objects
    def ssl_file_path(name, contents)
      file = Tempfile.new(name)
      @ssl_files << file
      file.write(contents)
      file.flush
      File.chmod(0o600, file.path)
      file.path
    end

    # Typhoeus replaces its trust store with the CA file it is given, so the system
    # roots that anchor the Common Platform chain have to be included alongside ours
    def ca_bundle_path
      bundle = [CA_CERT_PATH.read]
      bundle << File.read(system_ca_file) if system_ca_file && File.exist?(system_ca_file)
      ssl_file_path("ca_bundle", bundle.join("\n"))
    end

    def system_ca_file
      ENV.fetch(OpenSSL::X509::DEFAULT_CERT_FILE_ENV, OpenSSL::X509::DEFAULT_CERT_FILE)
    end

    def system_ca_dir
      dir = ENV.fetch(OpenSSL::X509::DEFAULT_CERT_DIR_ENV, OpenSSL::X509::DEFAULT_CERT_DIR)
      dir if dir.present? && Dir.exist?(dir)
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
