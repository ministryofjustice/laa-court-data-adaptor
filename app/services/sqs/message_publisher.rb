# frozen_string_literal: true

module Sqs
  class MessagePublisher < ApplicationService
    def initialize(message:, sqs_client: Aws::SQS::Client.new)
      @sqs_client = sqs_client
      @message = message
    end

    def call
      sqs_client.send_message(queue_url: queue_url, message_body: message) if messaging_enabled?
    end

    private

    def queue_url
      Rails.configuration.x.aws.sqs_url_link
    end

    def messaging_enabled?
      queue_url.present?
    end

    attr_reader :sqs_client, :message
  end
end
