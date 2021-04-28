module HmctsCommonPlatform
  class HearingDay
    attr_reader :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def sitting_day
      data[:sittingDay]
    end

    def listing_sequence
      data[:listingSequence]
    end

    def listed_duration_minutes
      data[:listedDurationMinutes]
    end
  end
end
