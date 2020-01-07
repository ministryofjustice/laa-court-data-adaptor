# frozen_string_literal: true

class CommonPlatformConnection < ApplicationService
  def initialize(host: Rails.configuration.x.common_platform_url)
    @host = host
  end

  def call
    Faraday.new host do |connection|
      connection.request :json
      connection.response :json, content_type: 'application/json'
      connection.adapter Faraday.default_adapter
    end
  end

  private

  attr_reader :host
end
