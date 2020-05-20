# frozen_string_literal: true

class OffenceSerializer
  include FastJsonapi::ObjectSerializer
  set_type :offences

  attributes :code, :order_index, :title, :mode_of_trial, :plea, :plea_date
end
