module HmctsCommonPlatform
  class HearingSummary
    attr_accessor :data

    delegate :short_oucode, :oucode_l2_code, to: :court_centre, prefix: true

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:hearingId]
    end

    def hearing_type
      data.dig(:hearingType, :description)
    end

    def estimated_duration
      data[:estimatedDuration]
    end

    def hearing_days
      Array(data[:hearingDays]).map do |hearing_day_data|
        HmctsCommonPlatform::HearingDay.new(hearing_day_data)
      end
    end

    def court_centre
      HmctsCommonPlatform::CourtCentre.new(data[:courtCentre])
    end

    def defence_counsel_ids
      defence_counsels.map(&:id)
    end

    def defence_counsels
      Array(data[:defenceCounsel]).map do |defence_counsel_data|
        HmctsCommonPlatform::DefenceCounsel.new(defence_counsel_data)
      end
    end
  end
end
