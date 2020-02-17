# frozen_string_literal: true

module Sqs
  class PublishUnlinkLaaReference < ApplicationService
    def initialize(maat_reference:, user_id:, unlink_reason_id:, unlink_reason_text:)
      @maat_reference = maat_reference
      @user_id = user_id
      @unlink_reason_id = unlink_reason_id
      @unlink_reason_text = unlink_reason_text
    end

    def call
      MessagePublisher.call(message: message)
    end

    private

    def message
      {
        maatId: maat_reference,
        userId: user_id,
        unlinkReasonId: unlink_reason_id,
        unlinkReasonText: unlink_reason_text
      }
    end

    attr_reader :maat_reference, :user_id, :unlink_reason_id, :unlink_reason_text
  end
end
