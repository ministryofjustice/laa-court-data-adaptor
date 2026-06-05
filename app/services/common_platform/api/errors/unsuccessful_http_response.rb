# frozen_string_literal: true

module CommonPlatform::Api::Errors
  class UnsuccessfulHttpResponse < StandardError
    # Common Platform was reached but returned a non-2xx HTTP status.
    def initialize(service:, status:, body: nil)
      super("#{service} failed with status #{status}: #{body}")
    end
  end
end
