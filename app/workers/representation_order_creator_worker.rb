# frozen_string_literal: true

class RepresentationOrderCreatorWorker
  include Sidekiq::Worker

  def perform(request_id, defendant_id, offences, maat_reference, defence_organisation)
    Current.set(request_id: request_id) do
      CommonPlatformApi::RepresentationOrderCreator.call(
        defendant_id: defendant_id,
        offences: offences,
        maat_reference: maat_reference,
        defence_organisation: defence_organisation,
      )
    end
  end
end
