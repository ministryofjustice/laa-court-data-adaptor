module MaatApi
  class SearchResponse
    COMMON_PLATFORM_PREFIX = "CP".freeze

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

    def existing_link?
      is_linked? || libra_id.present? || case_urn.present?
    end

    def linked_to_common_platform?
      libra_id.to_s.start_with?(COMMON_PLATFORM_PREFIX) && case_urn.present?
    end

    def linked_to_libra?
      libra_id.present? && !libra_id.start_with?(COMMON_PLATFORM_PREFIX)
    end

    def case_urn
      linking_detail["caseUrn"]
    end

    def link_state
      return :unlinked unless existing_link?
      return :linked_to_common_platform if linked_to_common_platform?
      return :linked_to_libra if is_linked? && linked_to_libra?

      :link_state_unknown
    end

  private

    attr_reader :http_response

    def libra_id
      linking_detail["libraId"]
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
