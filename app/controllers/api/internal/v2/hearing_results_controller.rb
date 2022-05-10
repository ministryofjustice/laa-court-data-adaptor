# frozen_string_literal: true

module Api
  module Internal
    module V2
      class HearingResultsController < ApplicationController
        def show
          hearing_result = CommonPlatform::Api::GetHearingResults.call(
            hearing_id: permitted_params[:hearing_id],
            sitting_day: permitted_params[:sitting_day],
          )

          if hearing_result.present?
            render json: HmctsCommonPlatform::HearingResulted.new(hearing_result&.body).to_json,
                   status: :ok
          else
            render json: {}, status: :not_found
          end
        end

      private

        def permitted_params
          params.permit(
            :hearing_id,
            :sitting_day,
          )
        end
      end
    end
  end
end
