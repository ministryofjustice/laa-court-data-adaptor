# frozen_string_literal: true

class LaaReference < ApplicationRecord
  validates :defendant_id, presence: true
  validates :maat_reference, presence: true, uniqueness: { conditions: -> { where(linked: true) } }
  validates :user_name, presence: true
  validates :unlink_reason_code,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: true }

  def unlink!(unlink_reason_code: nil)
    update!(linked: false, unlink_reason_code:)
  end

  def adjust_link_and_save!
    # Unlink the previous laa reference
    laa_ref_already_linked = LaaReference.find_by(maat_reference:, linked: true)
    laa_ref_already_linked.unlink! if laa_ref_already_linked.present?

    self.linked = true

    save!
  rescue ActiveRecord::ActiveRecordError => e
    Sentry.capture_exception(e)
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

  def self.retrieve_by_defendant_id_and_optional_maat_reference(defendant_id, maat_reference = nil)
    filters = { defendant_id:, linked: true }
    filters[:maat_reference] = maat_reference if maat_reference.present?
    find_by!(filters)
  rescue ActiveRecord::RecordNotFound
    attributes = filters.except(:linked).map { |k, v| "#{k}: '#{v}'" }.join(" and ")
    raise ActiveRecord::RecordNotFound, "LAA reference with #{attributes} not found or already unlinked!"
  end
end
