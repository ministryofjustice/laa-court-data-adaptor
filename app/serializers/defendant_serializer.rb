# frozen_string_literal: true

class DefendantSerializer
  include FastJsonapi::ObjectSerializer
  set_type :defendants

  attributes :first_name, :last_name, :date_of_birth, :national_insurance_number, :arrest_summons_number
  attribute :is_linked, &:linked?

  has_many :offences, record_type: :offences
end
