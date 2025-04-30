# frozen_string_literal: true

class HearingResult
  attr_reader :data, :skip_events

  delegate :blank?, to: :data

  def initialize(data, skip_events: false)
    @data = HashWithIndifferentAccess.new(data || {})
    @skip_events = skip_events
  end

  def hearing
    Hearing.new(data[:hearing], skip_events:)
  end

  def shared_time
    data[:sharedTime]
  end
end
