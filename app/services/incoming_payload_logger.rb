class IncomingPayloadLogger < ApplicationService
  def initialize(body, request_id, payload_type)
    @body = body
    @request_id = request_id
    @payload_type = payload_type
  end

  attr_reader :body, :request_id, :payload_type

  def call
    IncomingPayload.create!(
      payload_type:,
      body:,
      request_id:,
      compressed_body: Base64.encode64(Zlib::Deflate.deflate(body.to_json)),
    )
  rescue ActiveRecord::ActiveRecordError => e
    Sentry.capture_exception(
      e,
      tags: { request_id: },
    )
  end
end
