# frozen_string_literal: true

class Hearing < ApplicationRecord
  validates :body, presence: true
end
