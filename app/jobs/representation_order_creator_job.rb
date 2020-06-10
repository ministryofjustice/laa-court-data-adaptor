# frozen_string_literal: true

class RepresentationOrderCreatorJob < ApplicationJob
  queue_as :default

  def perform(contract:, request_id:)
    Current.set(request_id: request_id) do
      RepresentationOrderCreator.call(**contract)
    end
  end
end
