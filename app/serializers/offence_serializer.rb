# frozen_string_literal: true

class OffenceSerializer
  include FastJsonapi::ObjectSerializer
  set_type :offences
  attributes  :code,
              :order_index,
              :title,
              :legislation,
              :mode_of_trial,
              :mode_of_trial_reasons,
              :pleas
end
