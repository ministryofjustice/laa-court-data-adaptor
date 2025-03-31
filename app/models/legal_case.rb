class LegalCase < ApplicationRecord
  # Note that despite the table name, legal cases can be either
  # prosecution cases OR court applications
  self.table_name = "prosecution_cases"

  validates :body, presence: true
end
