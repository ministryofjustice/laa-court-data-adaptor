class ProsecutionCaseHearingRepullWorker
  include Sidekiq::Worker

  def perform(repull_id)
    repull = ProsecutionCaseHearingRepull.find(repull_id)
    repull.update!(status: :processing)

    repull.prosecution_case.body["hearingSummary"].each do |hearing|
      get_hearing_results(hearing)
    end

    repull.update!(status: :complete)
  rescue StandardError => e
    repull&.update!(status: :error)
    Sentry.capture_exception(e)
  end

  def get_hearing_results(hearing)
    CommonPlatform::Api::GetHearingResults.call(
      hearing_id: hearing["hearingId"],
      publish_to_queue: true,
    )
  end
end
