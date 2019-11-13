# frozen_string_literal: true

class HearingResultRecorder < ApplicationService
  def initialize(hearing_id)
    @hearing = Hearing.find_or_initialize_by(id: hearing_id)
  end

  def call
    response = HearingResultFetcher.call(hearing.id)
    hearing.body = response.body
    hearing.save
  end

  private

  attr_reader :hearing
end
