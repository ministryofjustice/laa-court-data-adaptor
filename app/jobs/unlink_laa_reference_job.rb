# frozen_string_literal: true

class UnlinkLaaReferenceJob < ApplicationJob
  queue_as :default

  def perform(contract)
    LaaReferenceUnlinker.call(**contract)
  end
end
