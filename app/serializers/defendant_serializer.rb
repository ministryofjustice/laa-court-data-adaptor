# frozen_string_literal: true

class DefendantSerializer
  include FastJsonapi::ObjectSerializer
  set_type :defendants

  attributes :name, :date_of_birth, :national_insurance_number, :arrest_summons_number, :maat_reference, :representation_order_date, :prosecution_case_id, :post_hearing_custody_status

  has_many :offences, record_type: :offences
  has_one :defence_organisation, record_type: :defence_organisations
  has_one :prosecution_case, record_type: :prosecution_case
end
