# frozen_string_literal: true

class ProsecutionCaseMaatLinkCreatorWorker
  include Sidekiq::Worker

  def perform(request_id, defendant_id, user_name, maat_reference)
    Current.set(request_id:) do
      ProsecutionCaseMaatLinkCreator.call(defendant_id, user_name, maat_reference)
    end
  end
end
