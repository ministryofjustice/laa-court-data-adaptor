# frozen_string_literal: true

class HearingSummary
  include ActiveModel::Model

  attr_accessor :body, :hearing_date

  def id
    body['hearingId']
  end

  def hearing_type
    body['hearingType']['description']
  end

  def hearing_days
    body['hearingDays'].map { |hearing_day| hearing_day['sittingDay'] }
  end
end
