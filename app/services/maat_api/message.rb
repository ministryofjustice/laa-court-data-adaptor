module MaatApi
  class Message
    attr_reader :object

    def initialize(object)
      @object = object
    end

    def generate
      {
        maatId: object.maat_reference,
        caseUrn: object.case_urn,
        jurisdictionType: object.jurisdiction_type,
        asn: object.defendant_asn,
        cjsAreaCode: object.cjs_area_code,
        caseCreationDate: object.case_creation_date.to_date.strftime("%Y-%m-%d"),
        cjsLocation: object.cjs_location,
        docLanguage: object.doc_language,
        proceedingsConcluded: object.proceedings_concluded,
        inActive: object.inactive,
        function_type: object.function_type,
        defendant: object.defendant,
        session: object.session,
        ccOutComeData: object.crown_court_outcome,
      }.compact
    end
  end
end
