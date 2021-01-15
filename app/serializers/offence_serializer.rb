# frozen_string_literal: true

class OffenceSerializer
  include JSONAPI::Serializer
  set_type :offences
  attributes  :code,
              :order_index,
              :title,
              :legislation,
              :mode_of_trial,
              :mode_of_trial_reasons,
              :pleas
end
