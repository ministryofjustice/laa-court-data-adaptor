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
      Array(data[:hearingDays] || data[:hearingDay]).map do |hearing_day_data|
        HmctsCommonPlatform::HearingDay.new(hearing_day_data)
      end
    end

    def court_centre
      HmctsCommonPlatform::CourtCentre.new(data[:courtCentre])
    end

    def defence_counsel_ids
      defence_counsels.map(&:id)
    end

    def jurisdiction_type
      data[:jurisdictionType]
    end

    def defendant_ids
      data[:defendantIds]
    end

    def defence_counsels
      Array(data[:defenceCounsel]).map do |defence_counsel_data|
        HmctsCommonPlatform::DefenceCounsel.new(defence_counsel_data)
      end
    end

    def to_json(*_args)
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |hearing_summary|
        hearing_summary.id id
        hearing_summary.hearing_type hearing_type
        hearing_summary.estimated_duration estimated_duration
        hearing_summary.defendant_ids defendant_ids
        hearing_summary.jurisdiction_type jurisdiction_type
        hearing_summary.court_centre court_centre.to_json
        hearing_summary.hearing_days hearing_days.map(&:to_json)
        hearing_summary.defence_counsels defence_counsels.map(&:to_json)
      end
    end
  end
end
