class TaggedLogger
  class << self
    def debug(message = nil, &block) = log(:debug, message, &block)
    def info(message = nil, &block)  = log(:info, message, &block)
    def warn(message = nil, &block)  = log(:warn, message, &block)
    def error(message = nil, &block) = log(:error, message, &block)
    def fatal(message = nil, &block) = log(:fatal, message, &block)

    # Sends a single line of JSON to OpenSearch so it indexes each field
    # separately. Also it keeps errors queryable by field: ie: "status: 500".
    def log_event(level, event, **fields)
      payload = { event:, request_id: Current.request_id }.merge(fields)

      # JSON.generate rather than .to_json so values are not HTML escaped
      Rails.logger.public_send(level, JSON.generate(payload.compact.as_json))
    end

  private

    def log(level, message)
      output = message || (yield if block_given?)
      Rails.logger.public_send(level, "(Request ID: #{Current.request_id}) #{output}") if output
    end
  end
end
