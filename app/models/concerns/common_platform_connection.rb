# frozen_string_literal: true

module CommonPlatformConnection
  extend ActiveSupport::Concern

  included do
    private

    def common_platform_connection
      @common_platform_connection ||= Faraday.new ENV.fetch('COMMON_PLATFORM_URL') do |connection|
        connection.request :json
        connection.response :json, content_type: 'application/json'
        connection.adapter Faraday.default_adapter
      end
    end
  end
end
