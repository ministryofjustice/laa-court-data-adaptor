# frozen_string_literal: true

module Api
  module Internal
    module V1
      class OffenceSerializer
        include JSONAPI::Serializer
        set_type :offences
        attributes :code,
                   :order_index,
                   :title,
                   :legislation,
                   :mode_of_trial,
                   :mode_of_trial_reasons,
                   :pleas

        has_many :judicial_results
      end
    end
  end
end
