class IncomingPayloadLogger < ApplicationService
  def initialize(body, request_id, payload_type, identifier)
    @body = body
    @request_id = request_id
    @payload_type = payload_type
    @identifier = identifier
  end

  attr_reader :body, :request_id, :payload_type, :identifier

  def call
    IncomingPayload.create!(
      payload_type:,
      body:,
      request_id:,
      identifier:,
    )
  rescue ActiveRecord::ActiveRecordError => e
    Sentry.capture_exception(
      e,
      tags: { request_id: },
    )
  end
end
