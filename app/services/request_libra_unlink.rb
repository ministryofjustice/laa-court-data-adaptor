# frozen_string_literal: true

class RequestLibraUnlink < ApplicationService
  REASON_TEXT = "XHIBIT migration: unlinking from LIBRA case"

  def initialize(maat_search_response, xhibit_case)
    @xhibit_case = xhibit_case
    @maat_id = maat_search_response.maat_id.to_s
  end

  def call
    Sqs::MessagePublisher.call(
      message: {
        defendantId: @xhibit_case.defendant_id,
        maatId: @maat_id,
        userId: User::SYSTEM_USERNAME,
        reasonId: LaaReference::OTHER_REASON_CODE,
        otherReasonText: REASON_TEXT,
      },
      queue_url: Rails.configuration.x.aws.sqs_url_unlink,
      log_info: { maat_reference: @maat_id },
    )
  end
end
