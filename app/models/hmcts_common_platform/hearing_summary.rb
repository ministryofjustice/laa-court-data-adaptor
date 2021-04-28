module HmctsCommonPlatform
  class HearingSummary
    attr_accessor :data

    delegate :short_oucode, :oucode_l2_code, to: :court_centre

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def hearing_id
      data["hearingId"]
    end

    def hearing_type
      data.dig("hearingType", "description")
    end

    def hearing_days
      Array(data["hearingDays"]).map do |hearing_day_data|
        HmctsCommonPlatform::HearingDay.new(hearing_day_data)
      end
    end

    def court_centre
      HmctsCommonPlatform::CourtCentre.new(data[:courtCentre])
    end
  end
end
