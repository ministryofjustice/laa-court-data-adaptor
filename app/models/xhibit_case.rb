class XhibitCase < ApplicationRecord
  validates :case_urn, presence: true
  validates :xhibit_case_number, presence: true
  validates :court_name, presence: true
  validates :ou_code, presence: true
  validates :case_type, presence: true
  validates :case_sub_type, presence: true
  validates :mode_of_trial, presence: true
  validates :defendant_id, presence: true
  validates :defendant_first_name, presence: true
  validates :defendant_last_name, presence: true
  validates :defendant_date_of_birth, presence: true
  validates :defendant_arrest_summons_number, presence: true
end
