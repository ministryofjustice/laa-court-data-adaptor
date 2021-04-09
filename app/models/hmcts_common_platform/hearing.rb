module HmctsCommonPlatform
  class Hearing
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def jurisdiction_type
      data[:jurisdictionType]
    end

    def court_centre_id
      data.dig(:courtCentre, :id)
    end

    def first_sitting_day_date
      data.dig(:hearingDays, 0, :sittingDay)
    end

    def prosecution_cases
      Array(data[:prosecutionCases]).map do |prosecution_case_data|
        HmctsCommonPlatform::ProsecutionCase.new(prosecution_case_data)
      end
    end
  end
end
