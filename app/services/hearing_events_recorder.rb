# frozen_string_literal: true

class HearingEventsRecorder < ApplicationService
  def initialize(hearing_id:, hearing_date:, body:)
    @hearing_event_recording = HearingEventRecording.find_or_initialize_by(hearing_id: hearing_id, hearing_date: hearing_date)
    @body = body
  end

  def call
    hearing_event_recording.update!(body: body)
    hearing_event_recording
  end

private

  attr_reader :hearing_event_recording, :body
end
