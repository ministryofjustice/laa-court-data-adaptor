# frozen_string_literal: true

module CommonPlatform
  class Connection < ApplicationService
    def initialize(
      host: Rails.configuration.x.common_platform_url,
      client_cert: Rails.configuration.x.client_cert,
      client_key: Rails.configuration.x.client_key
    )
      @host = host
      @client_cert = client_cert
      @client_key = client_key
    end

    def call
      Faraday.new host, options do |connection|
        connection.request :retry, retry_options
        connection.request :json
        connection.response :logger, Rails.logger
        connection.response :json, content_type: "application/json"
        connection.response :json, content_type: "application/vnd.unifiedsearch.query.laa.cases+json"
        connection.response :json, content_type: "text/plain"
        connection.adapter Faraday.default_adapter
      end
    end

  private

    def headers
      { "Ocp-Apim-Subscription-Key" => ENV["SHARED_SECRET_KEY"] }
    end

    def options
      return { headers: headers } if client_cert.blank?

      {
        headers: headers,
        ssl: {
          client_cert: OpenSSL::X509::Certificate.new(client_cert),
          client_key: OpenSSL::PKey::RSA.new(client_key),
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

    attr_reader :host, :client_cert, :client_key
  end
end
