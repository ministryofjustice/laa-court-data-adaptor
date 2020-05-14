# frozen_string_literal: true

class HearingsCreatorJob < ApplicationJob
  queue_as :default

  def perform(hearing)
    HearingsCreator.call(**hearing)
  end
end
