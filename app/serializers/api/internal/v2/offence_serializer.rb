# frozen_string_literal: true

module Api
  module Internal
    module V2
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

        attribute :verdict do |offence|
          {
            verdict_date: offence.verdict.verdict_date,
            originating_hearing_id: offence.verdict.originating_hearing_id,
            verdict_type: {
              id: offence.verdict.verdict_type_id,
              description: offence.verdict.verdict_type_description,
              category: offence.verdict.verdict_type_category,
              category_type: offence.verdict.verdict_type_category_type,
              sequence: offence.verdict.verdict_type_sequence,
            },
          }
        end
      end
    end
  end
end
