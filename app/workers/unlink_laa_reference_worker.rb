# frozen_string_literal: true

class UnlinkLaaReferenceWorker
  include Sidekiq::Worker

  def perform(request_id, defendant_id, user_name, unlink_reason_code, unlink_other_reason_text)
    Current.set(request_id:) do
      LaaReferenceUnlinker.call(
        defendant_id:,
        user_name:,
        unlink_reason_code:,
        unlink_other_reason_text:,
      )
    end
  end
end
