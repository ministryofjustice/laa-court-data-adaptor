# frozen_string_literal: true

class DefendantSerializer
  include FastJsonapi::ObjectSerializer
  set_type :defendants

  attributes :first_name, :last_name, :date_of_birth, :national_insurance_number

  has_many :offences, record_type: :offences
end
