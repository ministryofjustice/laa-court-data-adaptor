# frozen_string_literal: true

module Api
  module Internal
    module V1
      class HearingResultsController < ApplicationController
        def show
          hearing_result_data = CommonPlatform::Api::GetHearingResults.call(
            hearing_id: permitted_params[:id],
          )

          hearing_result = HearingResult.new(hearing_result_data)

          if hearing_result.blank?
            render json: {}, status: :not_found
          else
            render json: HearingSerializer.new(hearing_result.hearing, serialization_options),
                   status: :ok
          end
        end

      private

        def serialization_options
          { include: inclusions }.compact
        end

        def inclusions
          permitted_params[:include]&.split(",")
        end

        def permitted_params
          params.permit(
            :id,
            :include,
          )
        end
      end
    end
  end
end
