# frozen_string_literal: true

module Sqs
  class MessagePublisher < ApplicationService
    def initialize(message:, queue_url: nil, log_info: {}, sqs_client: Aws::SQS::Client.new)
      @sqs_client = sqs_client
      @queue_url = queue_url
      @log_info = log_info
      @message = message.merge(metadata: { laaTransactionId: Current.request_id })
    end

    def call
      if messaging_enabled?
        Rails.logger.info("Sending message: #{log_message}")
        sqs_client.send_message(queue_url: queue_url, message_body: message.to_json)
      end
    end

  private

    def messaging_enabled?
      queue_url.present?
    end

    def log_message
      log_info.merge(
        request_id: Current.request_id,
        queue: queue_url,
      ).map { |k, v| "#{k}: #{v}" }
       .join(", ")
    end

    attr_reader :sqs_client, :message, :queue_url, :log_info
  end
end
