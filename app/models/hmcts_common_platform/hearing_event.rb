module HmctsCommonPlatform
  class HearingEvent
    attr_reader :data

    delegate :blank?, :present?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:hearingEventId]
    end

    def definition_id
      data[:hearingEventDefinitionId]
    end

    def defence_counsel_id
      data[:defenceCounselId]
    end

    def recorded_label
      data[:recordedLabel]
    end

    def event_time
      data[:eventTime]
    end

    def last_modified_time
      data[:lastModifiedTime]
    end

    def alterable
      data[:alterable]
    end

    def note
      data[:note]
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
      Jbuilder.new do |hearing_event|
        hearing_event.id id
        hearing_event.definition_id definition_id
        hearing_event.defence_counsel_id defence_counsel_id
        hearing_event.recorded_label recorded_label
        hearing_event.event_time event_time
        hearing_event.last_modified_time last_modified_time
        hearing_event.alterable alterable
        hearing_event.note note
      end
    end
  end
end
