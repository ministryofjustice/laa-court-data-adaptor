module CommonPlatform::Api::Errors
  # Raised when the call to Common Platform fails:
  # - the TCP connection itself fails ("Faraday::ConnectionFailed")
  # - Common Platform returns an unsuccessful HTTP response.
  class FailedDependency < StandardError
    MAX_BODY_LENGTH = 500

    def self.from_response(service:, response:, context: nil)
      # In case of error, Common Platform API returns an HTML page.
      body = ActionView::Base.full_sanitizer.sanitize(response.body.to_s).strip.truncate(MAX_BODY_LENGTH)
      message = "#{service} - Unsuccessful response from Common Platform: status: #{response.status}, body: #{body}"
      message += " (#{context})" if context

      new(message)
    end

    def codes
      [:common_platform_connection_failed]
    end
  end
end
