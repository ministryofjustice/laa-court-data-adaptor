# frozen_string_literal: true

class OffenceSerializer
  include FastJsonapi::ObjectSerializer
  set_type :offences
  attributes  :code,
              :order_index,
              :title,
              :legislation,
              :mode_of_trial,
              :mode_of_trial_reason,
              :mode_of_trial_reason_code,
              :pleas,
              :plea,
              :plea_date
end
