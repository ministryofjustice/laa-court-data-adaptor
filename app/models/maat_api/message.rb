module MaatApi
  class Message
    attr_reader :object

    def initialize(object)
      @object = object
    end

    def generate
      {
        hearingId: object.hearing_id,
        maatId: object.maat_reference.to_i,
        caseUrn: object.case_urn,
        jurisdictionType: object.jurisdiction_type,
        asn: object.defendant_asn,
        cjsAreaCode: object.cjs_area_code,
        caseCreationDate: object.case_creation_date.to_date.strftime("%Y-%m-%d"),
        cjsLocation: object.cjs_location,
        docLanguage: doc_language,
        proceedingsConcluded: object.proceedings_concluded || false,
        inActive: object.inactive,
        functionType: object.function_type,
        defendant: object.defendant,
        session: object.session,
      }.compact
    end

  private

    def doc_language
      object.doc_language == "WELSH" ? "CY" : "EN"
    end
  end
end
