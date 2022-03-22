# frozen_string_literal: true

module Sqs
  class MessagePublisher < ApplicationService
    def initialize(message:, queue_url: nil, sqs_client: Aws::SQS::Client.new)
      @sqs_client = sqs_client
      @queue_url = queue_url
      @message = message.merge({ metadata: { laaTransactionId: Current.request_id } })
    end

    def call
      if messaging_enabled?
        Rails.logger.info("Sending message to queue: queue_url: #{queue_url}")
        sqs_client.send_message(queue_url: queue_url, message_body: message.to_json)
      end
    end

  private

    def messaging_enabled?
      queue_url.present?
    end

    attr_reader :sqs_client, :message, :queue_url
  end
end
