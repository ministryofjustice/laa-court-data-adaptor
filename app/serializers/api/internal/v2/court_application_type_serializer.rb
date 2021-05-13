module Api
  module Internal
    module V2
      class CourtApplicationTypeSerializer
        include JSONAPI::Serializer

        attributes :id, :description, :code, :category_code, :legislation, :applicant_appellant_flag
      end
    end
  end
end
