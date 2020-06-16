# frozen_string_literal: true

class LaaReferenceCreatorWorker
  include Sidekiq::Worker

  def perform(request_id, defendant_id, maat_reference = nil)
    Current.set(request_id: request_id) do
      LaaReferenceCreator.call(defendant_id: defendant_id, maat_reference: maat_reference)
    end
  end
end
