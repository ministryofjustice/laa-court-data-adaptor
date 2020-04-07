# frozen_string_literal: true

class RepresentationOrderCreatorJob < ApplicationJob
  queue_as :default

  def perform(contract)
    RepresentationOrderCreator.call(**contract)
  end
end
