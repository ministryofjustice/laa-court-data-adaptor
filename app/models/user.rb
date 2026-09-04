# frozen_string_literal: true

class User < ApplicationRecord
  SYSTEM_USERNAME = "SYSTEM"

  has_secure_password :auth_token

  validates :name, presence: true
end
