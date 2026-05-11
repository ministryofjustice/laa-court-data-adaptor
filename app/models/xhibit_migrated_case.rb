class XhibitMigratedCase < ApplicationRecord
  attribute :status, :string, default: "pending"
  enum :status, {
    pending: "pending",
    auto_linked: "auto_linked",
    manually_linked: "manually_linked",
    action_required: "action_required",
  }

  validates :case_urn, presence: true, uniqueness: {
    scope: %i[defendant_first_name defendant_last_name],
    message: lambda { |object, _data|
      "#{object.case_urn}, defendant: #{object.defendant_first_name} #{object.defendant_last_name} is already present"
    },
  }
  validates :xhibit_case_number, presence: true
  validates :court_name, presence: true
  validates :ou_code, presence: true
  validates :case_type, presence: true
  validates :case_sub_type, presence: true
  validates :mode_of_trial, presence: true
  validates :defendant_id, presence: true
  validates :defendant_first_name, presence: true
  validates :defendant_last_name, presence: true

  validate :defendant_date_of_birth_format, if: -> { defendant_date_of_birth_before_type_cast.present? }

private

  # Date example: 2002-11-03
  DATE_FORMAT_REGEX = /\A\d{4}-\d{2}-\d{2}\z/

  def defendant_date_of_birth_format
    raw = defendant_date_of_birth_before_type_cast
    return if raw.is_a?(Date)

    if raw.match?(DATE_FORMAT_REGEX)
      Date.strptime(raw, "%Y-%m-%d")
    else
      errors.add(:defendant_date_of_birth, "is invalid.")
    end
  rescue Date::Error
    errors.add(:defendant_date_of_birth, "is invalid.")
  end
end
