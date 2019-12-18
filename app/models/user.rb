# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password :auth_token

  validates :name, presence: true
end
