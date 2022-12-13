# frozen_string_literal: true

class HearingResultFetcherWorker
  include Sidekiq::Worker
  sidekiq_options retry: 7 # with exponential backoff, this retries over ~40 minutes

  def perform(request_id, hearing_id, sitting_day)
    Current.set(request_id: request_id) do
      HearingResultFetcher.call(hearing_id, sitting_day)
    end
  end
end
