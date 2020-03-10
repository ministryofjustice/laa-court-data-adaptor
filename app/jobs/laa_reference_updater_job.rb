# frozen_string_literal: true

class LaaReferenceUpdaterJob < ApplicationJob
  queue_as :default

  def perform(contract)
    LaaReferenceUpdater.call(contract)
  end
end
