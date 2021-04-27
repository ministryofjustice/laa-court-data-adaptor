module MaatApi
  class LaaReferenceMessage
    attr_reader :object

    def initialize(object)
      @object = object
    end

    def generate
      {
        maatId: object.maat_reference,
        caseUrn: object.case_urn,
        asn: object.defendant_asn,
        cjsAreaCode: object.cjs_area_code,
        createdUser: object.user_name,
        cjsLocation: object.cjs_location,
        docLanguage: object.doc_language,
        isActive: object.is_active?,
        defendant: object.defendant,
        sessions: object.sessions,
      }.compact
    end
  end
end
