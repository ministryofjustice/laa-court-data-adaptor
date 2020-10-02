# frozen_string_literal: true

class HearingSummary
  include ActiveModel::Model

  attr_accessor :body, :hearing_date

  def id
    body['hearingId']
  end

  delegate :short_oucode, :oucode_l2_code, to: :court_centre

  def hearing_type
    body['hearingType']['description']
  end

  def hearing_days
    body['hearingDays'].map { |hearing_day| hearing_day['sittingDay'] }
  end

  def hearing_in_past?
    hearing_days.max.to_date.past?
  end

  def hearing_in_future?
    hearing_days.max.to_date.future?
  end

  def resulted?
    Hearing.find_by(id: id).present?
  end

  private

  def court_centre
    @court_centre ||= HmctsCommonPlatform::Reference::CourtCentre.find(body['courtCentre']['id'])
  end
end
