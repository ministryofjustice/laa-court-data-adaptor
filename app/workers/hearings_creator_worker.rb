# frozen_string_literal: true

class HearingsCreatorWorker
  include Sidekiq::Worker

  def perform(request_id, hearing, shared_time)
    Current.set(request_id: request_id) do
      HearingsCreator.call(hearing: hearing.deep_transform_keys(&:to_sym), shared_time: shared_time)
    end
  end
end
