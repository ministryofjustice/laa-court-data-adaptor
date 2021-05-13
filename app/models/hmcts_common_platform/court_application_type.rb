module HmctsCommonPlatform
  class CourtApplicationType
    attr_reader :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:id]
    end

    def description
      data[:type]
    end

    def code
      data[:code]
    end

    def category_code
      data[:categoryCode]
    end

    def legislation
      data[:legislation]
    end

    def applicant_appellant_flag
      data[:applicantAppellantFlag]
    end
  end
end
