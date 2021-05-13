module Api
  module Internal
    module V2
      class CourtApplicationPartySerializer
        include JSONAPI::Serializer

        attribute :synonym
      end
    end
  end
end
