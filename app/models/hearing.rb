# frozen_string_literal: true

class Hearing < ApplicationRecord
  validates :body, presence: true

  def court_name
    hearing_body['courtCentre']['name']
  end

  def hearing_type
    hearing_body['type']['description']
  end

  def defendant_names
    defendants.map do |defendant|
      "#{defendant['personDefendant']['personDetails']['firstName']} #{defendant['personDefendant']['personDetails']['lastName']}"
    end
  end

  def hearing_events
    hearing_day_events.map { |hearing_day_event| HearingEvent.new(body: hearing_day_event) }
  end

  def hearing_event_ids
    hearing_events.map(&:id)
  end

  private

  def hearing_body
    body['hearing']
  end

  def prosecution_cases
    hearing_body['prosecutionCases']
  end

  def defendants
    prosecution_cases.flat_map { |prosecution_case| prosecution_case['defendants'] }
  end

  def hearing_event_recordings
    @hearing_event_recordings ||= hearing_body['hearingDays'].flat_map do |hearing_day|
      Api::GetHearingEvents.call(hearing_id: id, hearing_date: hearing_day['sittingDay'].to_date)
    end
  end

  def hearing_day_events
    hearing_event_recordings.flat_map { |recording| recording.body['events'] }
  end
end
