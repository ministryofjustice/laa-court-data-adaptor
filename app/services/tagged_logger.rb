class TaggedLogger
  class << self
  private

    LOGGER_METHODS = %i[debug info warn error fatal].freeze

    def method_missing(method, *args, &block)
      if is_log_request?(method)
        output = if args[0]
                   args[0]
                 elsif block_given?
                   yield
                 end
        Rails.logger.public_send(method, "(Request ID: #{Current.request_id}) #{output}") if output
      else
        super
      end
    end

    def respond_to_missing?(method, *args)
      is_log_request?(method) || super
    end

    def is_log_request?(method)
      LOGGER_METHODS.include?(method)
    end
  end
end
