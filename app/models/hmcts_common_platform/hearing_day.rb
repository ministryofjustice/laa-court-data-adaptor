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

    def has_shared_results
      data[:hasSharedResults]
    end

    def to_json(*_args)
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |hearing_day|
        hearing_day.sitting_day sitting_day
        hearing_day.listing_sequence listing_sequence
        hearing_day.listed_duration_minutes listed_duration_minutes
        hearing_day.has_shared_results has_shared_results
      end
    end
  end
end
