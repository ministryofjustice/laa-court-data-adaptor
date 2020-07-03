# frozen_string_literal: true

class HearingRecorder < ApplicationService
  def initialize(hearing_id:, body:, publish_to_queue:)
    @hearing = Hearing.find_or_initialize_by(id: hearing_id)
    @body = body
    @publish_to_queue = publish_to_queue
  end

  def call
    hearing.update(body: body)
    HearingsCreatorWorker.perform_async(Current.request_id, transformed_body[:hearing], transformed_body[:sharedTime]) if publish_to_queue

    hearing
  end

  private

  def transformed_body
    @transformed_body ||= body.to_hash.transform_keys(&:to_sym)
  end

  attr_reader :hearing, :body, :publish_to_queue
end
