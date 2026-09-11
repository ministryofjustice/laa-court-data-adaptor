class TaggedLogger
  class << self
    def debug(message = nil, &block) = log(:debug, message, &block)
    def info(message = nil, &block)  = log(:info, message, &block)
    def warn(message = nil, &block)  = log(:warn, message, &block)
    def error(message = nil, &block) = log(:error, message, &block)
    def fatal(message = nil, &block) = log(:fatal, message, &block)

    # Pass the fields as a structured payload so Semantic Logger indexes them
    # separately and keeps errors queryable by field, e.g. "status: 500".
    def log_event(level, event, **fields)
      payload = { event:, request_id: Current.request_id }.merge(fields)

      Rails.logger.public_send(level, payload.compact)
    end

  private

    def log(level, message)
      output = message || (yield if block_given?)
      Rails.logger.public_send(level, "(Request ID: #{Current.request_id}) #{output}") if output
    end
  end
end
