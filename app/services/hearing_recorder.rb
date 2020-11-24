# frozen_string_literal: true

class HearingRecorder < ApplicationService
  def initialize(hearing_id:, body:, publish_to_queue:)
    @hearing = Hearing.find_or_initialize_by(id: hearing_id)
    @body = body
    @publish_to_queue = publish_to_queue
  end

  def call
    hearing.update!(body: body)
    HearingsCreatorWorker.perform_async(Current.request_id, hearing.id) if publish_to_queue

    hearing
  end

private

  attr_reader :hearing, :body, :publish_to_queue
end
