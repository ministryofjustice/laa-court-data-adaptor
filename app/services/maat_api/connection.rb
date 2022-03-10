# frozen_string_literal: true

module MaatApi
  class Connection < ApplicationService
    def initialize(host: Rails.configuration.x.maat_api.api_url)
      @host = host
    end

    def call
      return if host.blank?

      Faraday.new host do |connection|
        connection.request :authorization, "Bearer", access_token.token
        connection.request :json
        connection.response :json, content_type: "application/json"
        connection.adapter Faraday.default_adapter
      end
    end

  private

    def access_token
      @access_token = new_access_token if @access_token.blank? || @access_token.expired?
    end

    def new_access_token
      client.client_credentials.get_token
    end

    def client
      @client ||= OAuth2::Client.new(
        Rails.configuration.x.maat_api.client_id,
        Rails.configuration.x.maat_api.client_secret,
        site: Rails.configuration.x.maat_api.oauth_url,
        token_url: "/oauth2/token",
        auth_scheme: :basic_auth,
      )
    end

    attr_reader :host
  end
end
