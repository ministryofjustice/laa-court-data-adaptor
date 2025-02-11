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
        connection.response :logger do |logger|
          logger.filter(/(defendantName=)([^&]+)/, '\1[FILTERED]')
          logger.filter(/(defendantDOB=)([^&]+)/, '\1[FILTERED]')
          logger.filter(/(defendantNINO=)([^&]+)/, '\1[FILTERED]')
        end
        connection.response :json, content_type: "application/json"
        connection.response :json, content_type: "application/vnd.unifiedsearch.query.laa.cases+json"
        connection.response :json, content_type: "text/plain"
        connection.adapter Faraday.default_adapter
      end
    end

    def call
      @connection
    end

    def self.reset!
      instance_variable_set(:@singleton__instance__, nil)
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
        methods: %i[delete get head options put post],
      }
    end
  end
end
