module MaatApi
  class SearchResponse
    def initialize(http_response)
      @http_response = http_response
    end

    def body
      http_response.body
    end

    def status
      http_response.status
    end

    def success?
      http_response.success?
    end

    def not_found?
      status == 404
    end

    def maat_id
      response["maatId"]
    end

    def no_existing_link?
      !is_linked? && !libra_id && !case_urn
    end

  private

    attr_reader :http_response

    def libra_id
      linking_detail["libraId"]
    end

    def case_urn
      linking_detail["caseUrn"]
    end

    def is_linked?
      response["isLinked"] == true
    end

    def linking_detail
      response["linkingDetail"] || {}
    end

    # Return the first item in the array by default, as this is the happy path
    # going forward, we'll handle the case of multiple results
    def response
      http_response&.body&.first || {}
    end
  end
end
