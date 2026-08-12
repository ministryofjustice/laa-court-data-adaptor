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

    def maat_id
      response["maatId"]
    end

  private

    attr_reader :faraday_response

    def_delegators :faraday_response, :status, :success?

    # Return the first item in the array by default, as this is the happy path
    # going forward, we'll handle the case of multiple results
    def response
      faraday_response&.body&.first || {}
    end
  end
end
