# frozen_string_literal: true

class CourtApplicationRepresentationOrderCreatorWorker
  include Sidekiq::Worker

  def perform(request_id, subject_id, offences, maat_reference, defence_organisation)
    Current.set(request_id:) do
      CommonPlatform::Api::CourtApplicationRepresentationOrderCreator.call(
        subject_id:,
        offences:,
        maat_reference:,
        defence_organisation:,
      )
    end
  end
end
