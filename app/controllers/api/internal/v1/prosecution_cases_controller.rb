# frozen_string_literal: true

module Api
  module Internal
    module V1
      class ProsecutionCasesController < ApplicationController
        def index
          @prosecution_cases = CommonPlatform::Api::SearchProsecutionCase.call(transformed_params)
          render json: ProsecutionCaseSummarySerializer.new(@prosecution_cases, serialization_options)
        end

      private

        def filtered_params
          params.require(:filter).permit(:prosecution_case_reference,
                                         :arrest_summons_number,
                                         :name,
                                         :date_of_birth,
                                         :date_of_next_hearing,
                                         :national_insurance_number)
        end

        def transformed_params
          filtered_params.to_hash.transform_keys(&:to_sym)
        end

        def serialization_options
          return { include: inclusions } if inclusions.present?

          {}
        end

        def inclusions
          params[:include]&.split(",")
        end
      end
    end
  end
end
