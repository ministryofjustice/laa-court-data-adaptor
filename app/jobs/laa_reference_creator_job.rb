# frozen_string_literal: true

class LaaReferenceCreatorJob < ApplicationJob
  queue_as :default

  def perform(contract)
    LaaReferenceCreator.call(**contract)
  end
end
