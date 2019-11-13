# frozen_string_literal: true

class HearingRecorder < ApplicationService
  def initialize(hearing_id)
    @hearing = Hearing.find_or_initialize_by(id: hearing_id)
  end

  def call
    response = HearingFetcher.call(hearing.id)
    hearing.body = response.body
    hearing.save
  end

  private

  attr_reader :hearing
end
