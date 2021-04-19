# frozen_string_literal: true

module Api
  module Internal
    module V1
      class DefenceOrganisationSerializer
        include JSONAPI::Serializer
        set_type :defence_organisation

        attributes :name, :address1, :address2, :address3, :address4, :address5, :postcode
      end
    end
  end
end
