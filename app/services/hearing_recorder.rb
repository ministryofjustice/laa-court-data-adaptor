# frozen_string_literal: true

class HearingRecorder < ApplicationService
  def initialize(hearing_id:, body:, publish_to_queue:)
    @hearing = Hearing.find_or_initialize_by(id: hearing_id)
    @body = body
    @publish_to_queue = publish_to_queue
  end

  def call
    begin
      enforce_contract!
      hearing.update!(body: body)
      publish_hearing_to_queue if publish_to_queue
    rescue Errors::ContractError => e
      report_to_sentry(e)
    end

    hearing
  end

private

  def enforce_contract!
    unless hearing_contract.success?
      message = "Hearing contract failed with: #{hearing_contract.errors.to_hash}"
      raise Errors::ContractError, message
    end
  end

  def report_to_sentry(error)
    Sentry.capture_exception(
      error,
      tags: {
        request_id: Current.request_id,
        hearing_id: @hearing.id,
      },
    )
  end

  def hearing_contract
    HearingContract.new.call(body)
  end

  def publish_hearing_to_queue
    HearingsCreatorWorker.perform_async(Current.request_id, hearing.id)
  end

  attr_reader :hearing, :body, :publish_to_queue
end
