module HmctsCommonPlatform
  class CaseSummary
    attr_reader :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def case_status
      data[:caseStatus]
    end

    def prosecution_case_id
      data[:prosecutionCaseId]
    end

    def prosecution_case_reference
      data[:prosecutionCaseReference]
    end

    def as_json
      {
        case_status:,
        prosecution_case_id:,
        prosecution_case_reference:,
      }
    end
  end
end
