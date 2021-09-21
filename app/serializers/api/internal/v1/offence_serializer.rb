module Api
  module Internal
    module V1
      class OffenceSerializer
        include JSONAPI::Serializer

        attributes :code,
          :order_index,
          :title,
          :legislation

        attribute :plea do |object|
          {
            plea_value: object.plea.plea_value,
            plea_date: object.plea.plea_date,
          }
        end

        attribute :mode_of_trial_reason do |object|
          {
            description: object.allocation_decision_mot_reason_description,
            code: object.allocation_decision_mot_reason_code,
          }
        end
      end
    end
  end
end
