class IncomingPayload < ApplicationRecord
  validates :request_id, presence: true
end
