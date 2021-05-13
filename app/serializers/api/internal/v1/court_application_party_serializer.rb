module Api
  module Internal
    module V1
      class CourtApplicationPartySerializer
        include JSONAPI::Serializer

        attribute :synonym
      end
    end
  end
end
