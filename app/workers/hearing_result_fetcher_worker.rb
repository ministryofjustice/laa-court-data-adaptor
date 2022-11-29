# frozen_string_literal: true

class HearingResultFetcherWorker
  include Sidekiq::Worker

  def perform(request_id, hearing_id, sitting_day)
    Current.set(request_id: request_id) do
      HearingResultFetcher.call(hearing_id, sitting_day)
    end
  end
end
