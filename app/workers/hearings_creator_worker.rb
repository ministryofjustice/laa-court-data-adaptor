# frozen_string_literal: true

class HearingsCreatorWorker
  include Sidekiq::Worker

  def perform(request_id, hearing_id)
    Current.set(request_id: request_id) do
      HearingsCreator.call(hearing_id: hearing_id)
    end
  end
end
