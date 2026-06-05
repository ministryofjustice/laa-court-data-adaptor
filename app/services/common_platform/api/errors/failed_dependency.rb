module CommonPlatform::Api::Errors
  # Raises "Faraday::ConnectionFailed", which is when the TCP connection itself fails.
  class FailedDependency < StandardError
    def codes
      [:common_platform_connection_failed]
    end
  end
end
