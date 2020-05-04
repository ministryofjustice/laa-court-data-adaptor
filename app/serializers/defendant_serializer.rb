# frozen_string_literal: true

class DefendantSerializer
  include FastJsonapi::ObjectSerializer
  set_type :defendants

  attributes :name, :date_of_birth, :national_insurance_number, :arrest_summons_number, :maat_reference, :representation_order

  has_many :offences, record_type: :offences
end
