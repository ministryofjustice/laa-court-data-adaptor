# frozen_string_literal: true

class LaaReferenceCreatorJob < ApplicationJob
  queue_as :default

  def perform(contract:, request_id:)
    Current.set(request_id: request_id) do
      LaaReferenceCreator.call(**contract)
    end
  end
end
