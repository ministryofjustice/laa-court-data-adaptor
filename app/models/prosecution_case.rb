# frozen_string_literal: true

class ProsecutionCase < ApplicationRecord
  validates :body, presence: true
end
