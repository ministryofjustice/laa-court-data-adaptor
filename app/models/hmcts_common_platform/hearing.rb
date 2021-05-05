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
  end
end
