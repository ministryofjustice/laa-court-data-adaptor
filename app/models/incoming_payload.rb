class IncomingPayload < ApplicationRecord
  validates :payload_type, presence: true
end
