# frozen_string_literal: true

class LaaReferenceUpdaterJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Api::RecordLaaReference.new(*args).call
  end
end
