# frozen_string_literal: true

class HearingRecorder < ApplicationService
  def initialize(hearing_id:, body:)
    @hearing = Hearing.find_or_initialize_by(id: hearing_id)
    @body = body
  end

  def call
    hearing.update(body: body)
    HearingsCreatorWorker.perform_async(Current.request_id, transformed_body[:hearing], transformed_body[:sharedTime])

    hearing
  end

  private

  def transformed_body
    @transformed_body ||= body.to_hash.transform_keys(&:to_sym)
  end

  attr_reader :hearing, :body
end
