# frozen_string_literal: true

class HearingsCreatorJob < ApplicationJob
  queue_as :default

  def perform(body:, request_id:)
    Current.set(request_id: request_id) do
      HearingsCreator.call(**body)
    end
  end
end
