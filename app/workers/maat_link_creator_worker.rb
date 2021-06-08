# frozen_string_literal: true

class MaatLinkCreatorWorker
  include Sidekiq::Worker

  def perform(request_id, defendant_id, user_name, maat_reference)
    Current.set(request_id: request_id) do
      MaatLinkCreator.call(defendant_id, user_name, maat_reference)
    end
  end
end
