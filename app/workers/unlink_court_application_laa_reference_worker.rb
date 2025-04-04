# frozen_string_literal: true

class UnlinkCourtApplicationLaaReferenceWorker
  include Sidekiq::Worker

  def perform(request_id, subject_id, user_name, unlink_reason_code, unlink_other_reason_text)
    Current.set(request_id:) do
      CourtApplicationLaaReferenceUnlinker.call(
        subject_id:,
        user_name:,
        unlink_reason_code:,
        unlink_other_reason_text:,
      )
    end
  end
end
