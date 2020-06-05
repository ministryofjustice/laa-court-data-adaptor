# frozen_string_literal: true

class HearingRecorder < ApplicationService
  def initialize(hearing_id:, body:)
    @hearing = Hearing.find_or_initialize_by(id: hearing_id)
    @body = body
  end

  def call
    hearing.update(body: body)
    HearingsCreatorJob.perform_later(**transformed_body)
    hearing
  end

  private

  def transformed_body
    body.to_hash.deep_transform_keys(&:to_sym)
  end

  attr_reader :hearing, :body
end
