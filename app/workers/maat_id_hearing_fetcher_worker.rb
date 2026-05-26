# frozen_string_literal: true

class MaatIdHearingFetcherWorker
  include Sidekiq::Worker
  sidekiq_options queue: :hearing_repull, retry: 0

  def perform(maat_id)
    laa_reference = LaaReference.find_by!(maat_reference: maat_id, linked: true)
    prosecution_case_id = ProsecutionCaseDefendantOffence
                            .where(defendant_id: laa_reference.defendant_id)
                            .pick(:prosecution_case_id)

    CommonPlatform::Api::ProsecutionCaseHearingsFetcher.call(prosecution_case_id:)
  end
end
