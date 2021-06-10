module HmctsCommonPlatform
  class HearingResulted
    attr_reader :data

    delegate :blank?, to: :data

    delegate :jurisdiction_type, :court_centre_id, :first_sitting_day_date, to: :hearing, prefix: true

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def hearing
      HmctsCommonPlatform::Hearing.new(data[:hearing])
    end

    def shared_time
      data[:sharedTime]
    end
  end
end
