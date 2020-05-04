# frozen_string_literal: true

class DefenceOrganisationSerializer
  include FastJsonapi::ObjectSerializer
  set_type :defence_organisation

  attributes :name, :address1, :address2, :address3, :address4, :address5, :postcode
end
