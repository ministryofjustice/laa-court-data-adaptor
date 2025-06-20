# frozen_string_literal: true

module Api
  module Internal
    module V2
      class ProsecutionCasesController < ApplicationController
        # Get/Post /api/internal/v2/prosecution_cases
        def index
          case_summaries = CommonPlatform::Api::SearchProsecutionCase.call(transformed_params)

          case_summaries_json = Array(case_summaries).map do |case_summary|
            HmctsCommonPlatform::ProsecutionCaseSummary.new(case_summary.body).to_json
          end

          render json: { total_results: case_summaries_json.count, results: case_summaries_json }
        end

      private

        def transformed_params
          filtered_params.to_hash.deep_symbolize_keys
        end

        def filtered_params
          params.require(:filter).permit(:prosecution_case_reference,
                                         :arrest_summons_number,
                                         :name,
                                         :date_of_birth,
                                         :date_of_next_hearing,
                                         :national_insurance_number)
        end
      end
    end
  end
end
