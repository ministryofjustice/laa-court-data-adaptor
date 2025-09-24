class IncomingPayloadLogger < ApplicationService
  def initialize(params, request_id)
    @params = params
    @request_id = request_id
  end

  def call
    IncomingPayload.create!(
      body: @params,
      request_id: @request_id,
      compressed_body: Base64.encode64(Zlib::Deflate.deflate(@params.to_json)),
    )
  rescue ActiveRecord::ActiveRecordError => e
    Sentry.capture_exception(
      e,
      tags: { request_id: @request_id },
    )
  end
end
