# frozen_string_literal: true

class DefendantSerializer
  include FastJsonapi::ObjectSerializer
  set_type :defendants

  attributes :first_name, :last_name, :date_of_birth, :national_insurance_number, :gender, :address_1, :address_2, :address_3, :address_4, :address_5, :postcode

  has_many :offences, record_type: :offences
end
