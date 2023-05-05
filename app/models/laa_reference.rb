# frozen_string_literal: true

class LaaReference < ApplicationRecord
  validates :defendant_id, presence: true
  validates :maat_reference, presence: true, uniqueness: { conditions: -> { where(linked: true) } }
  validates :user_name, presence: true

  def unlink!
    update!(linked: false)
  end

  def adjust_link_and_save!
    # Unlink the previous laa reference
    laa_ref_already_liked = LaaReference.find_by(maat_reference: maat_reference, linked: true)
    laa_ref_already_liked.unlink! if laa_ref_already_liked.present?

    self.linked = true

    save!
  rescue ActiveRecord::ActiveRecordError => e
    Sentry.capture_exception(e)
  end

  def self.unlink_all!(maat_ref)
    where(maat_reference: maat_ref).update_all(linked: false)
  end

  def dummy_maat_reference?
    return false if maat_reference.nil?

    maat_reference.start_with?("A", "Z")
  end

  def self.generate_linking_dummy_maat_reference
    "A#{ActiveRecord::Base.connection.execute("SELECT nextval('dummy_maat_reference_seq')")[0]['nextval']}"
  end

  def self.generate_unlinking_dummy_maat_reference
    "Z#{ActiveRecord::Base.connection.execute("SELECT nextval('dummy_maat_reference_seq')")[0]['nextval']}"
  end
end
