module HmctsCommonPlatform
  class HearingResulted
    attr_reader :data

    delegate :blank?, :present?, to: :data

    delegate :jurisdiction_type, :court_centre_id, :court_centre, :first_sitting_day_date, to: :hearing, prefix: true

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def hearing
      HmctsCommonPlatform::Hearing.new(data[:hearing])
    end

    def shared_time
      data[:sharedTime]
    end

    def to_json(*_args)
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |hearing_result|
        hearing_result.hearing hearing.to_json
        hearing_result.shared_time shared_time
      end
    end
  end
end
