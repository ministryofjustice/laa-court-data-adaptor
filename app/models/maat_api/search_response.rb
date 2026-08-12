module MaatApi
  class SearchResponse
    extend Forwardable

    def_delegator :faraday_response, :body

    def initialize(faraday_response)
      @faraday_response = faraday_response
    end

    def not_found?
      status == 404
    end

  private

    attr_reader :faraday_response

    def_delegators :faraday_response, :status, :success?
  end
end
