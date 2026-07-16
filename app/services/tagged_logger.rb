class TaggedLogger
  class << self
    def debug(message = nil, &block) = log(:debug, message, &block)
    def info(message = nil, &block)  = log(:info, message, &block)
    def warn(message = nil, &block)  = log(:warn, message, &block)
    def error(message = nil, &block) = log(:error, message, &block)
    def fatal(message = nil, &block) = log(:fatal, message, &block)

  private

    def log(level, message)
      output = message || (yield if block_given?)
      Rails.logger.public_send(level, "(Request ID: #{Current.request_id}) #{output}") if output
    end
  end
end
