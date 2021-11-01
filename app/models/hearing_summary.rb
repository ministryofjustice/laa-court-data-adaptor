# frozen_string_literal: true

class HearingSummary
  include ActiveModel::Model

  attr_accessor :body, :hearing_date

  def id
    body["hearingId"]
  end

  delegate :short_oucode, :oucode_l2_code, to: :court_centre

  def hearing_type
    body["hearingType"]["description"]
  end

  def sitting_days
    hearing_days.map(&:sitting_day)
  end

  def hearing_in_past?
    date_of_hearing.past?
  end

  def hearing_in_future?
    date_of_hearing.future?
  end

  def resulted?
    Hearing.find_by(id: id).present?
  end

  def date_of_hearing
    sitting_days.max&.to_date
  end

  def court_centre
    HmctsCommonPlatform::CourtCentre.new(body["courtCentre"])
  end

private

  def hearing_days
    Array(body["hearingDays"]).map do |hearing_day_data|
      HmctsCommonPlatform::HearingDay.new(hearing_day_data)
    end
  end
end
