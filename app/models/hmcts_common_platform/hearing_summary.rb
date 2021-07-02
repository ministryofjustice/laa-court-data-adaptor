module HmctsCommonPlatform
  class HearingSummary
    attr_accessor :data

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

    def court_centre_short_oucode
      hmcts_common_platform_reference_court_centre.short_oucode
    end

    def court_centre_oucode_l2_code
      hmcts_common_platform_reference_court_centre.oucode_l2_code
    end

  private

    def hmcts_common_platform_reference_court_centre
      @hmcts_common_platform_reference_court_centre ||= HmctsCommonPlatform::Reference::CourtCentre.find(court_centre.id)
    end
  end
end
