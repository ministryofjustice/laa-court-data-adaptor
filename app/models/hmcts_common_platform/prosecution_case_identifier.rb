module HmctsCommonPlatform
  class ProsecutionCaseIdentifier
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def case_urn
      data[:caseURN]
    end

    def prosecution_authority_id
      data[:prosecutionAuthorityId]
    end

    def prosecution_authority_code
      data[:prosecutionAuthorityCode]
    end

    def prosecution_authority_name
      data[:prosecutionAuthorityName]
    end

    def to_json(*_args)
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |prosecution_case_identifier|
        prosecution_case_identifier.case_urn case_urn
        prosecution_case_identifier.prosecution_authority_id prosecution_authority_id
        prosecution_case_identifier.prosecution_authority_code prosecution_authority_code
        prosecution_case_identifier.prosecution_authority_name prosecution_authority_name
      end
    end
  end
end
