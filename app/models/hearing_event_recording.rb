# frozen_string_literal: true

class HearingEventRecording < ApplicationRecord
  validates :body, presence: true
end
