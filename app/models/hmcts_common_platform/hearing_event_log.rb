module HmctsCommonPlatform
  class HearingEventLog
    attr_reader :data

    delegate :blank?, :present?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def hearing_id
      data[:hearingId]
    end

    def has_active_hearing
      data[:hasActiveHearing]
    end

    def events
      Array(data[:events]).map do |hearing_event_data|
        HmctsCommonPlatform::HearingEvent.new(hearing_event_data)
      end
    end

    def to_json(*_args)
      return {} if attrs.all? { |_k, v| v.blank? }

      attrs
    end

  private

    def attrs
      @attrs ||= to_builder.attributes!
    end

    def to_builder
      Jbuilder.new do |hearing_event_log|
        hearing_event_log.hearing_id hearing_id
        hearing_event_log.has_active_hearing has_active_hearing
        hearing_event_log.events events.map(&:to_json)
      end
    end
  end
end
