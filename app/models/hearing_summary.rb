# frozen_string_literal: true

class HearingSummary < ApplicationRecord
  validates :body, presence: true

  attr_accessor :hearing_date

  def id
    body['hearingId']
  end

  def jurisdiction_type
    body['jurisdictionType']
  end

  def court_centre_id
    court_centre['id']
  end

  def court_centre_name
    body['courtCenter']['name']
  end

  def court_centre_welsh_name
    body['courtCenter']['welshName']
  end

  def court_centre_room_id
    body['courtCenter']['roomId']
  end

  def court_centre_room_name
    body['courtCenter']['roomName']
  end

  def court_centre_welsh_room_name
    body['courtCenter']['welshRoomName']
  end

  def court_centre_address_1
    court_centre_address['address 1']
  end

  def court_centre_address_2
    court_centre_address['address 2']
  end

  def court_centre_address_3
    court_centre_address['address 3']
  end

  def court_centre_address_4
    court_centre_address['address 4']
  end

  def court_centre_address_5
    court_centre_address['address 5']
  end

  def court_centre_postcode
    court_centre_address['postcode']
  end

  def hearing_type_id
    body['hearingType']['id']
  end

  def hearing_type_description
    body['hearingType']['description']
  end

  def hearing_type_code
    body['hearingType']['code']
  end

  def court_centre
    body['courtCenter']
  end

  def court_centre_address
    court_centre['address']
  end

  def defendants
    body['defendants']
  end
end
