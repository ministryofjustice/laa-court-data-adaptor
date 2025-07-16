# frozen_string_literal: true

class RepresentationOrderCreatorWorker
  include Sidekiq::Worker

  def perform(request_id, defendant_id, offences, maat_reference, defence_organisation)
    Current.set(request_id:) do
      CommonPlatform::Api::RepresentationOrderCreator.call(
        defendant_id:,
        offences:,
        maat_reference:,
        defence_organisation:,
      )
    end
  end
end
