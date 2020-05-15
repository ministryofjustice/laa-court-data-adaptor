# frozen_string_literal: true

class CommonPlatformConnection < ApplicationService
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
      connection.request :json
      connection.response :json, content_type: 'application/json'
      connection.response :json, content_type: 'application/vnd.unifiedsearch.query.laa.cases+json'
      connection.response :json, content_type: 'text/plain'
      connection.adapter Faraday.default_adapter
    end
  end

  private

  def options
    return {} if client_cert.blank?

    {
      ssl: {
        client_cert: OpenSSL::X509::Certificate.new(client_cert),
        client_key: OpenSSL::PKey::RSA.new(client_key)
      }
    }
  end

  attr_reader :host, :client_cert, :client_key
end
