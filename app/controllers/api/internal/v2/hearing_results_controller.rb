# frozen_string_literal: true

module Api
  module Internal
    module V2
      class HearingResultsController < ApplicationController
        def show
          hearing_result_data = CommonPlatform::Api::GetHearingResults.call(
            hearing_id: permitted_params[:hearing_id],
            publish_to_queue: permitted_params[:publish_to_queue],
          )

          hearing_result = HmctsCommonPlatform::HearingResulted.new(hearing_result_data)

          if hearing_result.blank?
            render json: {}, status: :not_found
          else
            render json: hearing_result.to_json,
                   status: :ok
          end
        end

      private

        def permitted_params
          params.permit(
            :hearing_id,
            :publish_to_queue,
          )
        end
      end
    end
  end
end
