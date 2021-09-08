# frozen_string_literal: true

class PastHearingsFetcherWorker
  include Sidekiq::Worker

  def perform(request_id, prosecution_case_id)
    Current.set(request_id: request_id) do
      CommonPlatform::Api::ProsecutionCaseHearingsFetcher.call(prosecution_case_id: prosecution_case_id)
    end
  end
end
