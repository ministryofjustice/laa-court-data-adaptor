module Api
  module Internal
    module V2
      class CourtApplicationSerializer
        include JSONAPI::Serializer

        attribute :received_date

        has_one :type, serializer: :court_application_type
        has_many :respondents, serializer: :court_application_party
        has_many :judicial_results
      end
    end
  end
end
