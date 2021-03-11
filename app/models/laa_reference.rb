# frozen_string_literal: true

class LaaReference < ApplicationRecord
  self.ignored_columns = %w[dummy_maat_reference]

  validates :defendant_id, presence: true
  validates :maat_reference, presence: true, uniqueness: { conditions: -> { where(linked: true) } }
  validates :user_name, presence: true

  def unlink!
    update!(linked: false)
  end

  def dummy_maat_reference?
    maat_reference.start_with?("A", "Z")
  end

  def self.generate_linking_dummy_maat_reference
    "A#{ActiveRecord::Base.connection.execute("SELECT nextval('dummy_maat_reference_seq')")[0]['nextval']}"
  end

  def self.generate_unlinking_dummy_maat_reference
    "Z#{ActiveRecord::Base.connection.execute("SELECT nextval('dummy_maat_reference_seq')")[0]['nextval']}"
  end
end
