# frozen_string_literal: true

module Sqs
  class PublishUnlinkLaaReference < ApplicationService
    def initialize(maat_reference:, user_name:, unlink_reason_code:, unlink_reason_text:)
      @maat_reference = maat_reference
      @user_name = user_name
      @unlink_reason_code = unlink_reason_code
      @unlink_reason_text = unlink_reason_text
    end

    def call
      MessagePublisher.call(message: message, queue_url: Rails.configuration.x.aws.sqs_url_unlink)
    end

    private

    def message
      {
        maatId: maat_reference,
        userId: user_name,
        unlinkReasonId: unlink_reason_code,
        unlinkReasonText: unlink_reason_text
      }
    end

    attr_reader :maat_reference, :user_name, :unlink_reason_code, :unlink_reason_text
  end
end
