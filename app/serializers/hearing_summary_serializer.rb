# frozen_string_literal: true

class HearingSummarySerializer
  include FastJsonapi::ObjectSerializer
  set_type :hearing_summaries

  attributes :jurisdiction_type, :court_centre_id, :court_centre_name, :court_centre_welsh_name, :court_centre_room_id, :court_centre_room_name, :court_centre_welsh_room_name,
             :court_centre_address_1, :court_centre_address_2, :court_centre_address_3, :court_centre_address_4, :court_centre_address_5, :court_centre_postcode, :hearing_type_id,
             :hearing_type_description, :hearing_type_code, :hearing_date, :defendants
end
