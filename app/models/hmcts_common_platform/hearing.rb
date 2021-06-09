module HmctsCommonPlatform
  class Hearing
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
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

    def court_applications
      Array(data[:courtApplications]).map do |court_application_data|
        HmctsCommonPlatform::CourtApplication.new(court_application_data)
      end
    end
  end
end
