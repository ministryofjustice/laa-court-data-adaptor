# frozen_string_literal: true

class HearingRecorder < ApplicationService
  def initialize(hearing_id, body = nil)
    @hearing = Hearing.find_or_initialize_by(id: hearing_id)
    @body = body.presence || HearingFetcher.call(hearing.id).body
  end

  def call
    hearing.update(body: body)
    hearing
  end

  private

  attr_reader :hearing, :body
end
