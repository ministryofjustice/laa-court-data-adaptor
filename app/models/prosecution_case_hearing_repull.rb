class ProsecutionCaseHearingRepull < ApplicationRecord
  belongs_to :prosecution_case, optional: true
  belongs_to :hearing_repull_batch

  def as_json
    {
      status:,
      urn:,
      maat_ids:,
    }
  end
end
