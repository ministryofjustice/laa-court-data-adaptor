# frozen_string_literal: true

class UnlinkProsecutionCaseLaaReferenceWorker
  include Sidekiq::Worker

  def perform(request_id, defendant_id, user_name, unlink_reason_code, unlink_other_reason_text, maat_reference = nil)
    Current.set(request_id:) do
      ProsecutionCaseLaaReferenceUnlinker.call(
        defendant_id:,
        user_name:,
        unlink_reason_code:,
        unlink_other_reason_text:,
        maat_reference:,
      )
    end
  end
end
