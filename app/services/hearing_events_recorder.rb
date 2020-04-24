# frozen_string_literal: true

class HearingEventsRecorder < ApplicationService
  def initialize(hearing_id:, events:)
    @hearing = Hearing.find_or_initialize_by(id: hearing_id)
    @events = events
  end

  def call
    hearing.update(events: events)
    hearing
  end

  private

  attr_reader :hearing, :events
end
