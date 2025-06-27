class HearingRepullBatch < ApplicationRecord
  has_many :prosecution_case_hearing_repulls, dependent: :destroy

  def as_json
    {
      id:,
      repulls: prosecution_case_hearing_repulls,
      complete: prosecution_case_hearing_repulls.where.not(status: :complete).none?,
    }
  end
end
