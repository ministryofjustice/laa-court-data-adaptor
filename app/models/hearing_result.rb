# frozen_string_literal: true

class HearingResult
  attr_reader :data, :load_events

  delegate :blank?, to: :data

  def initialize(data, load_events: true)
    @data = HashWithIndifferentAccess.new(data || {})
    @load_events = load_events
  end

  def hearing
    Hearing.new(data[:hearing], load_events:)
  end

  def shared_time
    data[:sharedTime]
  end
end
