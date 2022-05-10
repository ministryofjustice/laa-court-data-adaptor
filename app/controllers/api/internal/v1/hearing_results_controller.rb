# frozen_string_literal: true

module Api
  module Internal
    module V1
      class HearingResultsController < ApplicationController
        def show
          @hearing = CommonPlatform::Api::GetHearingResults.call(
            hearing_id: permitted_params[:id],
            sitting_day: permitted_params[:sitting_day],
          )

          render json: HearingSerializer.new(@hearing, serialization_options)
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
            :sitting_day,
            :include,
          )
        end
      end
    end
  end
end
