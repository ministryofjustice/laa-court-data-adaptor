# frozen_string_literal: true

class Hearing < ApplicationRecord
  validates :body, presence: true, unless: :events?
  validates :events, presence: true, unless: :body?
end
