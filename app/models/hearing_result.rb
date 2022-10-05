# frozen_string_literal: true

class HearingResult
  attr_reader :data

  delegate :blank?, to: :data

  def initialize(data)
    @data = HashWithIndifferentAccess.new(data || {})
  end

  def hearing
    Hearing.new(data[:hearing])
  end

  def shared_time
    data[:sharedTime]
  end
end
