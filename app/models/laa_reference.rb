# frozen_string_literal: true

class LaaReference < ApplicationRecord
  validates :defendant_id, presence: true
  validates :maat_reference, presence: true, uniqueness: { conditions: -> { where(linked: true) } }
  validates :user_name, presence: true
end
