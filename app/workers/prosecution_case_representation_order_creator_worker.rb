# frozen_string_literal: true

class ProsecutionCaseRepresentationOrderCreatorWorker
  include Sidekiq::Worker

  def perform(request_id, defendant_id, offences, maat_reference, defence_organisation)
    Current.set(request_id:) do
      CommonPlatform::Api::ProsecutionCaseRepresentationOrderCreator.call(
        defendant_id:,
        offences:,
        maat_reference:,
        defence_organisation:,
      )
    end
  end
end
