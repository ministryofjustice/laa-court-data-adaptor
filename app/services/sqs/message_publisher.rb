# frozen_string_literal: true

module Sqs
  class MessagePublisher < ApplicationService
    def initialize(message:, queue_url: nil, sqs_client: Aws::SQS::Client.new)
      @sqs_client = sqs_client
      @message = message
      @queue_url = queue_url
    end

    def call
      sqs_client.send_message(queue_url: queue_url, message_body: message.to_json) if messaging_enabled?
    end

    private

    def messaging_enabled?
      queue_url.present?
    end

    attr_reader :sqs_client, :message, :queue_url
  end
end
