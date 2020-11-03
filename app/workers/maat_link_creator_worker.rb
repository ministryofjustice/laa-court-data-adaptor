# frozen_string_literal: true

class MaatLinkCreatorWorker
  include Sidekiq::Worker

  def perform(request_id, laa_reference_id)
    Current.set(request_id: request_id) do
      MaatLinkCreator.call(laa_reference_id: laa_reference_id)
    end
  end
end
