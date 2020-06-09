# frozen_string_literal: true

class UnlinkLaaReferenceJob < ApplicationJob
  queue_as :default

  def perform(contract:, request_id:)
    Current.set(request_id: request_id) do
      LaaReferenceUnlinker.call(**contract)
    end
  end
end
