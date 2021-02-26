# frozen_string_literal: true

class HearingRecorder < ApplicationService
  def initialize(hearing_id:, body:, publish_to_queue:)
    @hearing = Hearing.find_or_initialize_by(id: hearing_id)
    @body = body
    @publish_to_queue = publish_to_queue
  end

  def call
    if hearing_contract.success?
      hearing.update!(body: body)
      publish_hearing_to_queue if publish_to_queue
    end

    hearing
  end

private

  def hearing_contract
    HearingContract.new.call(body)
  end

  def publish_hearing_to_queue
    HearingsCreatorWorker.perform_async(Current.request_id, hearing.id)
  end

  attr_reader :hearing, :body, :publish_to_queue
end
