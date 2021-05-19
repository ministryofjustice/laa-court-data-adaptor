module Api
  module Internal
    module V1
      class JudicialResultSerializer
        include JSONAPI::Serializer

        attributes :id, :cjs_code, :text
      end
    end
  end
end
